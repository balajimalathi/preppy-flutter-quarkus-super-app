# Jank and memory: validating Flutter performance

This guide explains how to use Dart DevTools (and related tooling) to interpret **memory** and **jank**, how to tell **healthy behavior** from a **leak**, and why a **simple page** can still show **slow frames**.

It is written for this repo’s stack (Flutter, Riverpod, Go_router) but applies broadly.

---

## How do I validate?

You validate **memory** and **jank** with different DevTools tabs, but the same rules apply: **Profile mode**, **real device when possible**, **fixed reproduction steps**, and **compare before vs after** (snapshots for memory; frames for jank).

### Validate memory (short procedure)

1. Run the app with **`flutter run --profile`** (or a profile/release build on device).
2. Open **DevTools → Memory**. Let the app **idle** on a known screen.
3. Tap **GC** (if available), then take **Snapshot A** (or record baseline chart position).
4. Run a **written script** (e.g. dashboard → practice → back × 10). End on the same screen as step 2.
5. **GC** again, then take **Snapshot B**.
6. **Diff** B vs A. Sort by **largest growth** in instance count or retained size.
7. **Pass:** growth flattens after a few cycles; no unbounded growth for types you do not expect to retain. **Fail:** same classes climb every cycle after GC; drill **retaining paths** for those types.

Exporting a **CSV class list** alone is a **sanity check** only: it does not prove leaks or that extra routes are “mounted.”

### Validate jank (short procedure)

1. Run with **`flutter run --profile`**. Do **not** trust debug-mode frame times for “is it good?”
2. Open **DevTools → Performance** (or **Flutter → Performance**). Enable **frame chart** / timeline as your version shows.
3. Turn on the in-app **performance overlay** for a quick **UI vs raster** split: with `flutter run --profile`, press **`P`** in the terminal; or set `showPerformanceOverlay: true` on `MaterialApp` (typically **debug** only). In **profile**, prefer the **Performance** page for timing.
4. Reproduce the jank (scroll, open page, etc.).
5. Select a **red / slow** frame in the chart. Open **CPU profiler** (bottom-up or flame) for that time range.
6. **Pass:** rare misses, mostly idle; hotspots are one-off (first frame, image decode once). **Fail:** repeated long `build`, layout, sync I/O, or raster spikes every scroll tick.

If jank only appears in **Debug**, treat profile as the source of truth before changing architecture.

---

## Part 1 — Memory tab: what it is (and is not)

### What the Memory page shows

- **Live Dart heap usage** over time (RSS / process memory also appears at the OS level; the Dart heap is only one part).
- **Heap snapshots** and **class tables**: counts and sizes **per class name** (e.g. `DashboardScreen`, `ListTile`).
- **Allocation tracking** (when enabled): where new objects were allocated.

### What it does *not* show by itself

- **Which route is visible.** The heap lists **types that have at least one live instance**, not “widgets on screen.”
- **Proof of a leak** without a **process**: baseline → actions → GC → compare (see below).
- **Full meaning of a CSV export** of class totals: useful for a quick scan, but **not** a substitute for snapshots, diffs, or retaining paths.

### “Class in memory” vs “screen fully built”

| Observation | Typical meaning |
|-------------|-----------------|
| **One** row for `FooScreen`, **very small** size (e.g. tens of bytes), **1 instance** | Usually **class / type metadata** because the library is loaded or referenced (e.g. route table), **not** a full subtree. |
| **Many** instances of `StatefulElement` / your state class / `RenderObject` subclasses tied to a screen you **left**, size **growing** after GC | Investigate **retention** (possible leak or route keeping state alive). |

Your app builds a **single** `GoRouter` that imports all feature routes; seeing **every** `*Screen` type in a class list is **expected** and does **not** mean every screen is mounted.

---

## Part 2 — How to validate memory (repeatable workflow)

Always treat memory like a **controlled experiment**: same build mode, same device, same sequence.

### 1) Use the right build mode

| Mode | Use for memory / performance? |
|------|--------------------------------|
| **Debug** | **Poor** for judging final behavior: extra asserts, timing, service extensions, less representative layout. |
| **Profile** | **Best default** for DevTools: realistic optimizations, still attachable. |
| **Release** | Smallest / fastest; use when you need to confirm profile findings without debug overhead. |

**Rule:** If numbers look “wrong,” first ask: **Was this Profile or Debug?**

### 2) Baseline snapshot

1. Open **DevTools → Memory**.
2. Trigger **GC** (garbage collect) if the tool exposes it.
3. Take **Heap snapshot A** (or note current heap chart after idle).

### 3) Exercise the app, then GC again

1. Perform a **fixed script** (e.g. open dashboard → open practice → back → repeat N times).
2. Return to a **stable** screen (e.g. dashboard).
3. **GC** again.
4. Take **Heap snapshot B**.

### 4) Compare (diff)

- Use **diff** between B and A (or “compare snapshots” in your DevTools version).
- Sort by **delta instances** / **delta retained size**.

**Healthy:**

- After a few cycles, **deltas shrink** toward zero (within noise).
- Heap curve shows **sawtooth** (allocations + GC), not an **endless staircase**.

**Suspicious (investigate further):**

- Same classes **keep growing** after GC when you are **not** accumulating user data on purpose.
- **Many** duplicate instances of **controllers**, **streams**, **listeners**, or **State** classes for screens you believe you **popped**.

### 5) Drill in: retaining paths (when available)

For a class that grows without explanation:

1. Open the snapshot detail for that class.
2. Inspect **inbound references / retaining path** (wording varies by DevTools version).

Look for accidental **static** lists, **singletons** holding `BuildContext`, **controllers** not `dispose`d, **StreamSubscription** not cancelled, or **global caches** keyed by route without eviction.

### 6) Allocation profiling (optional, high signal)

Enable **allocation tracking** for a short window while you reproduce a flow. It attributes allocations to **call sites** — useful when the heap diff says “lots of `X`” but you need **why**.

### 7) Platform memory (optional)

On mobile, also watch **Xcode Instruments** (iOS) or **Android Studio Profiler** for **native** growth (images, platform views, JNI). Dart heap can look flat while **process RSS** climbs.

---

## Part 3 — Leak vs “looks weird but OK”

### Usually OK

- **One small row per screen class** in a class histogram (types loaded with the router).
- **Temporary spikes** during navigation or heavy lists, then **drop after GC**.
- **Riverpod / provider** infrastructure objects; counts often **stable** after warm-up.

### Investigate as a possible leak

- **Monotonic** heap growth over **many** GC cycles with **idle** UI.
- After **popping** a route, **retained** `State` / `Element` / **controllers** for that route still present and **referenced**.
- **Repeated** open/close of the same screen increases instances **without bound**.

**Note:** A **memory leak** is sustained **unreachable** growth or **reachable but never released** references you did not intend. DevTools helps you find **suspicious retention**; you confirm with code (dispose, `ref.onDispose`, cancel subscriptions, avoid holding `context` in long-lived objects).

---

## Part 4 — Jank: definitions and tools

### Frame budget

- **60 fps** → ~**16.67 ms** per frame (combined work on UI and raster pipelines; think of it as a budget, not two independent 16 ms slots).
- **120 fps** → ~**8.33 ms**.

A **janky frame** is one that **misses** the budget (shader compilation, layout, build, paint, I/O on the UI isolate, etc.).

### Where to look in DevTools

1. **Performance** (or **Flutter DevTools → Performance**)  
   - **Frame chart** / timeline: which frames exceeded budget.  
   - **CPU profiler** (sampled): what ran on the **UI** thread during a bad frame.

2. **Flutter inspector → Performance overlay** (in-app)  
   - Quick **UI vs raster** bars per frame.

3. **`flutter run --profile`** + interact  
   - Reproduces real-world timing better than debug.

### UI thread vs raster thread (short)

- **UI thread:** Dart `build`, layout, much of layer tree work. Heavy **sync** work here blocks frames.
- **Raster thread (GPU):** painting, sometimes expensive **shader** or **texture** work.

Jank can come from **either**; the overlay helps you see **which side** is hot.

---

## Part 5 — Why a “simple” page can still jank

Below are **common** causes even when the widget tree looks small.

### 1) Debug mode

Debug builds are **much slower** (asserts, JIT, extra checks). **Always re-check jank in Profile mode** before optimizing.

### 2) First-frame / one-off costs

- **First** navigation to a route: route parsing, **first** `build` of dependencies, **image** decode, **font** metric work.
- **Shader compilation** (historically more visible on some Skia paths; **Impeller** on iOS reduces shader-compile stalls but does not remove **all** first-hit GPU work).

**Mitigation ideas:** warm up critical paths, reduce first-build work, preload small assets where justified.

### 3) Work on the UI isolate

Even a “simple” UI can hitch if you do on the main isolate:

- **Large JSON** parse / `compute`-worthy work  
- **Synchronous** file I/O  
- **Expensive** sorting/filtering of big lists **during build**  
- **Logging** huge strings every frame  

**Fix:** move CPU-heavy work to **`compute`**, **isolates**, or **async** with chunked processing; never block the UI thread for tens of ms.

### 4) Over-rebuilding (Riverpod / `setState`)

- **`ref.watch`** too high in the tree watches **broad** providers → large subtrees rebuild often.  
- **Selectors** (`select`) or **splitting providers** reduces rebuild scope.

**Symptom:** CPU profiler shows lots of time in **`build`** for widgets that should be static.

### 5) Lists and layout

- **`ListView`** without `itemExtent` / `prototypeItem` can force **expensive layout** for large lists.  
- **`ShrinkWrap` + scrollables** nested badly → layout explosion.  
- **`LayoutBuilder`** in hot paths doing non-trivial work every layout.

### 6) Images and decoding

- Large images decoded at **intrinsic** size then scaled in UI.  
**Fix:** resize assets, use `cacheWidth` / `cacheHeight` where appropriate, appropriate formats.

### 7) Animations and implicit animations

- Many simultaneous animations or rebuilding **animated** parents every frame.

### 8) Platform channels and plugins

- **Synchronous** platform calls or chatty channels during scroll/build.

### 9) DevTools / tracing overhead

Attaching profilers adds overhead. Compare **relative** hotspots (before/after a change), not only absolute ms.

---

## Part 6 — Validation checklists

Use these as a **session script**. Check every box that applies; note device, Flutter version, and build mode in your notes.

### Pre-flight (always)

- [ ] **Build mode:** `flutter run --profile` or profile/release **APK/IPA** — not Debug — for final judgment.
- [ ] **Device:** physical device preferred (simulators skew timing and memory).
- [ ] **Warm-up:** open the app once, dismiss dialogs, then **idle 10–15 s** before first measurement (reduces cold-start noise).
- [ ] **Script:** write down the exact taps (e.g. “Dashboard → Practice → back” × 10) so you can **repeat** and **diff** runs.

---

### Memory validation checklist

| Step | Action | Done |
|------|--------|------|
| 1 | Attach DevTools **Memory** after app is running in **Profile**. | [ ] |
| 2 | Navigate to your **baseline route** (e.g. dashboard); **idle**. | [ ] |
| 3 | Trigger **GC**; take heap **Snapshot A** (name it, e.g. `after-idle`). | [ ] |
| 4 | Execute your **navigation script** (fixed N iterations). | [ ] |
| 5 | Return to **same baseline route** as step 2; **idle** a few seconds. | [ ] |
| 6 | **GC**; take heap **Snapshot B** (`after-script`). | [ ] |
| 7 | Open **Compare / Diff** (B − A). Sort by **delta retained** or **delta instance count**. | [ ] |
| 8 | For top 5 growing types: note whether they are **expected** (caches, session data) or **unexpected** (dangling `State`, `StreamController`, listeners). | [ ] |
| 9 | If unexpected: open class detail → **retaining path** / inbound refs → map to code (`dispose`, `ref.onDispose`, cancel subscriptions). | [ ] |
| 10 | **Optional:** enable **allocation tracking** for one script run; correlate allocations with **call stacks**. | [ ] |
| 11 | **Optional:** **Xcode Instruments** / **Android Studio Memory** — confirm **process RSS** vs Dart-only story (images, native plugins). | [ ] |
| 12 | **Repeat** steps 3–7 once more from a **cold start** if the first run looked noisy. | [ ] |

**Memory “pass” criteria**

- [ ] After several navigate-away / pop cycles, **diff vs baseline** shows **no unbounded** growth for UI `Element` / feature `State` you thought was disposed.
- [ ] Chart is roughly **sawtooth**, not a **steady staircase** while idle.
- [ ] Seeing **every `*Screen` type** in a single class export with **1 tiny instance** is **normal** for a central router; **not** automatic evidence of a leak.

**Memory “investigate” criteria**

- [ ] Same type’s instance count **increases linearly** with repeats of “open screen → close screen” after **GC**.
- [ ] Heap **keeps rising** with UI **fully idle** for minutes.
- [ ] Diff shows large retained **controllers**, **timers**, or **platform stream** wrappers you did not intend to keep.

---

### Jank / frame validation checklist

| Step | Action | Done |
|------|--------|------|
| 1 | **`flutter run --profile`** on target device. | [ ] |
| 2 | Open DevTools **Performance**; show **frame timeline** / FPS chart. | [ ] |
| 3 | (Optional) Enable **performance overlay** to label **UI** vs **Raster** bars. | [ ] |
| 4 | Reproduce jank with the **same gesture** each time (e.g. fling list 3×). | [ ] |
| 5 | Click a **janky frame** (> 16.7 ms @ 60 Hz, or > 8.3 ms @ 120 Hz). | [ ] |
| 6 | Note whether **UI** or **Raster** (or both) exceeded budget. | [ ] |
| 7 | Open **CPU profiler** for that frame’s window; identify top **Dart** frames (`build`, `layout`, your code). | [ ] |
| 8 | If UI-bound: scan for **sync file/JSON**, **huge rebuilds**, **layout** in `build`, **ListView** misuse (`shrinkWrap`, unbounded height). | [ ] |
| 9 | If raster-bound: note **first-time** effects vs every frame; check **images**, **opacity/backdrop** layers, **shader** first-frame cost. | [ ] |
| 10 | Re-run the same gesture **after warm-up** (second and third fling). If only the **first** is bad, treat as **startup / shader / cache** before micro-optimizing widgets. | [ ] |
| 11 | Compare same steps in **Debug** vs **Profile**; if jank is **debug-only**, do not optimize release code paths based on debug alone. | [ ] |

**Jank “pass” criteria**

- [ ] **Profile** mode: most frames under budget; misses are **rare** or clearly **first-frame** / one-off.
- [ ] CPU profile of bad frames points to **fixable** hot spots or acceptable **one-shot** work.

**Jank “investigate” criteria**

- [ ] **Profile** mode: **many** consecutive frames over budget during a **repeated** gesture.
- [ ] CPU shows the same **sync** work or **full-tree build** on every frame while scrolling.

---

### CSV / export validation (Memory tab exports)

When you only have a **class totals CSV** (no diff):

- [ ] Treat it as a **catalog of loaded types**, not a route list.
- [ ] Rows with **1 instance** and **tiny** size for `*Screen` are usually **not** “full page built.”
- [ ] For leak suspicion, still run the **snapshot A → script → GC → snapshot B → diff** flow above; CSV alone is **insufficient**.

---

### Session sign-off (optional)

- [ ] **Memory:** documented Snapshot A/B names, script, device, build mode; pass/fail against criteria above.
- [ ] **Jank:** screenshot or note of **one** analyzed bad frame + UI vs raster + top CPU frame.
- [ ] **Follow-up:** filed issue or TODO only if **Profile** reproduces and criteria say “investigate.”

---

## Part 7 — References

- [Flutter performance best practices](https://docs.flutter.dev/perf/best-practices)  
- [Flutter performance profiling](https://docs.flutter.dev/tools/devtools/performance)  
- [Flutter memory profiling](https://docs.flutter.dev/tools/devtools/memory)  
- [Dart DevTools](https://docs.flutter.dev/tools/devtools/overview)  

---

## Document maintenance

- **DevTools UI** changes between versions; menu names (**Memory**, **Performance**, **Diff**) may move slightly — prefer the official Flutter docs links above when in doubt.

When in doubt, **Profile mode + diffed heap snapshots + CPU sample of a bad frame** is the most reliable triad for this codebase.
