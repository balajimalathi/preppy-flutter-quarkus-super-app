# core_analytics

Vendor-neutral analytics for Preppy: a small [`AnalyticsContract`](lib/src/analytics_contract.dart), Riverpod [`analyticsProvider`](lib/src/analytics_provider.dart), and pluggable backends (Firebase/GA4 today; PostHog, Mixpanel, etc. can be added under `lib/src/impl/`).

Feature code should depend on **`AnalyticsContract`** (via `ref.read(analyticsProvider)` or your own abstractions), not on Firebase or other SDKs directly.

## Configuration

Values come from compile-time defines (for example `--dart-define-from-file=config/env.dev.json` when running the app).

| Define | Purpose |
|--------|---------|
| `ANALYTICS_ENABLED` | When not `true`, [`resolveAnalytics`](lib/src/analytics_provider.dart) returns [`NoopAnalytics`](lib/src/impl/noop_analytics.dart): all calls are no-ops. |
| `ANALYTICS_BACKENDS` | Comma-separated backend ids (default `firebase`). Example: `firebase` or `firebase,posthog` once additional impls exist. Unknown ids are ignored. |

[`AppEnv`](../env/lib/src/app_env.dart) in `core_env` exposes `analyticsEnabled` and `analyticsBackends` for the same values.

The app shell still calls `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(...)` after `Firebase.initializeApp` so the native SDK respects your privacy flag; that is separate from the Dart-side noop.

## Using analytics in the app

### In a `ConsumerWidget` / `ConsumerStatefulWidget`

```dart
import 'package:core_analytics/core_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton(
      onPressed: () async {
        final analytics = ref.read(analyticsProvider);
        await analytics.logEvent('cta_tapped', parameters: {'surface': 'my_screen'});
      },
      child: const Text('Go'),
    );
  }
}
```

Use `ref.read(analyticsProvider)` for one-off actions (fires once per interaction). Use `ref.watch(analyticsProvider)` only if you need the implementation to drive UI when env or backend wiring changes (uncommon).

### Screen views

```dart
await ref.read(analyticsProvider).logScreenView(
  'SyllabusHome',
  screenClass: 'SyllabusHomeRoute',
  parameters: {'tab': 'overview'},
);
```

Parameter maps use `Map<String, Object?>`. Values are normalized for Firebase (strings and numbers; other types are stringified where needed).

### Identity and properties

```dart
final a = ref.read(analyticsProvider);
await a.setUserId('user-123');
await a.setUserProperty('exam_track', 'NEET');
```

### Import via `core_di` (optional)

If the app already imports `core_di`’s barrel, `core_analytics` is re-exported there, so a single import can expose `analyticsProvider` alongside other shared providers.

## Barrel import

```dart
import 'package:core_analytics/core_analytics.dart';
```

This exposes `AnalyticsContract`, `AnalyticsException`, `analyticsProvider`, `resolveAnalytics`, and `FirebaseAnalytics` (only for app bootstrap / rare cases). Prefer **`AnalyticsContract`** everywhere else.

## Testing

Override `appEnvProvider` (and optionally `analyticsProvider`) on your `ProviderScope`:

```dart
import 'package:core_env/core_env.dart';

await tester.pumpWidget(
  ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        const AppEnv(
          environment: DevEnvironment(),
          baseUrl: 'https://test',
          firebaseProjectId: 'test',
          authBackend: AuthBackend.firebase,
          analyticsEnabled: false,
          crashlyticsEnabled: false,
          analyticsBackends: ['firebase'],
          grpcHost: '',
          grpcPort: 443,
          grpcUseTls: true,
          graphqlUrl: '',
        ),
      ),
      analyticsProvider.overrideWithValue(const NoopAnalytics()),
    ],
    child: const MyAppUnderTest(),
  ),
);
```

For unit tests without Riverpod, use [`resolveAnalytics`](lib/src/analytics_provider.dart) with a constructed `AppEnv`, or depend on `NoopAnalytics` / a fake `AnalyticsContract`.

## Extending with a mixin

You can centralize access and typed helpers (event names, parameter shapes) in a mixin that expects a `WidgetRef` or `Ref`. `core_analytics` does not ship a mixin so you stay free to choose naming and placement (e.g. `lib/analytics/app_analytics_mixin.dart` in `preppy_app` or a small internal package).

Example pattern with **`WidgetRef`**:

```dart
import 'package:core_analytics/core_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin AnalyticsContext on ConsumerStatefulWidget {
  // Subclasses use ConsumerState<...>
}

mixin AnalyticsStateMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  AnalyticsContract get analytics => ref.read(analyticsProvider);

  Future<void> track(String name, [Map<String, Object?>? parameters]) =>
      analytics.logEvent(name, parameters: parameters);
}
```

Then in a `ConsumerState`:

```dart
class _MyScreenState extends ConsumerState<MyScreen> with AnalyticsStateMixin<MyScreen> {
  @override
  void initState() {
    super.initState();
    analytics.logScreenView('MyScreen');
  }
}
```

If you prefer **`Ref`** (not tied to `WidgetRef`), pass `Ref` into notifiers/services or use a mixin `on Notifier` / `on AsyncNotifier` that calls `ref.read(analyticsProvider)`.

## Adding a new backend

1. Add the SDK to this package’s [`pubspec.yaml`](pubspec.yaml).
2. Implement `AnalyticsContract` in `lib/src/impl/<name>_analytics.dart`.
3. Extend the `switch` in [`resolveAnalytics`](lib/src/analytics_provider.dart) with a new case (e.g. `posthog`).
4. Document the new id in `ANALYTICS_BACKENDS` for your env JSON files.

Use [`CompositeAnalytics`](lib/src/impl/composite_analytics.dart) automatically when multiple backends are configured.
