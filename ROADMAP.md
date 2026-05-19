# Preppy Roadmap

Preppy is a self-preparation system for school, university, and competitive-exam students. It turns a learner's own syllabi, textbooks, notes, PDFs, images, videos, PPTs, docs, spreadsheets, and previous-year questions into notebook-based workflows for syllabus coverage, source-grounded practice, spaced repetition, PYQ/mock-exam analysis, and adaptive daily planning.

This roadmap translates the product direction in [ABOUT.md](ABOUT.md) and the architecture in [TECHNICAL.md](TECHNICAL.md) into testable, deliverable milestones.

## How To Read This Roadmap

### Milestone Definitions

| Milestone | Meaning | Release bar |
| --- | --- | --- |
| MVP | Public beta | Anyone can sign up, complete onboarding, create a notebook, upload syllabus/source material, generate a study plan, and complete the core daily practice loop on Flutter and web. |
| v1 | Beta hardening and product depth | The beta is reliable, measurable, and deeper for notebook planning, PYQ/mock-exam workflows, notifications, and retention instrumentation. |
| v2 | AI platform and multimodal expansion | AI execution moves behind clearer runtime boundaries, streaming experiences are live, richer material types are supported, and one competitive-exam track is deepened. |
| v3 | Learning operating system | Preppy becomes a multi-domain learning platform with advanced personalization, B2B/teacher workflows, and optional community features only if validated. |

### Deliverable Format

Every deliverable uses the same structure:

| Field | Meaning |
| --- | --- |
| ID | Stable roadmap identifier for planning and issue tracking. |
| Owner | Main implementation area: Backend, AI, Flutter, Web, Infra, Product, or QA. |
| Status | Current repo baseline: Implemented, Stubbed, Planned, or New. |
| Depends on | Prior deliverables that must be complete first. |
| Done when | Testable acceptance criteria. |
| Verify | Concrete command, automated test, or manual check. |

### Current Baseline

| Area | Current status | Evidence | Roadmap implication |
| --- | --- | --- | --- |
| Flutter shell | Implemented shell | `apps/preppy_app` with route composition for auth, dashboard, ingestion, practice, PYQ, and syllabus features | Product screens can be built incrementally inside existing feature packages. |
| Web shell | Implemented shell | `web/apps/web` exists with a minimal Next app | Web can become the responsive public-beta surface without creating a new app first. |
| Firebase auth | Implemented | `FirebaseAuthenticationMechanism`, profile sync, and authenticated user APIs exist | MVP can build onboarding and profile settings on the existing auth foundation. |
| Quarkus REST resources | Stubbed | Ingestion, taxonomy, question, SRS, PYQ, and dashboard resources exist with early behavior | MVP work should replace stubs with persisted, typed APIs. |
| Postgres and Flyway | Implemented foundation | Initial schema covers users, ingested docs, chunks, syllabus items, questions, flashcards, SRS state, and daily plans | MVP should evolve this schema rather than introduce a second product store. |
| PYQ schema | Implemented foundation | A PYQ migration exists | MVP can start with user-uploaded PYQs and defer curated datasets. |
| Redis | Configured | Local infra and backend config exist | Use later for cache, job coordination, rate limits, and quotas. |
| Qdrant | Configured | Local infra and dependency config exist | Keep production RAG and embedding work mostly in v2 unless MVP generation needs limited indexing. |
| AI module | Planned | No separate Java AI runtime exists yet | MVP should use the existing backend interface boundary, then extract AI execution in v2. |
| gRPC | Stubbed | Proto surface exists for ping and job status | MVP can use REST polling first; v2 should add production streaming. |

## Product North Star

Preppy should feel like a private learning operating system: bring your own syllabus, textbooks, notes, media, and PYQs; Preppy maps them into notebook topic workspaces, generates source-grounded practice, schedules revision, and tells you what to do today. The product wins by being structured, plan-aware, and provenance-first, not by being another generic document chatbot.

## Milestone Overview

```mermaid
flowchart LR
  subgraph mvp [MVP Public Beta]
    Onboard[Onboarding]
    Notebook[Notebook]
    Mapping[Syllabus Mapping]
    Plan[Adaptive Plan]
    Practice[Practice Loop]
    Nudges[Mobile Nudges]
  end
  subgraph v1 [v1 Depth]
    PyqUI[PYQ Mock Exams]
    Formats[Question Formats]
    Ops[Ops and Retention]
  end
  subgraph v2 [v2 AI and Multimodal]
    AiMod[Java AI Module]
    Streams[gRPC Streams]
    Media[Rich Media]
    ExamTrack[Exam Track]
  end
  subgraph v3 [v3 Learning OS]
    B2B[Teacher B2B]
    Personalize[Personalization]
    MultiDomain[Multi Domain]
  end
  mvp --> v1 --> v2 --> v3
```

## MVP: Public Beta

MVP is intentionally larger than an internal alpha because the release bar is public beta. The first gate is still internal dogfood, so the product does not open signup before the core loop works on real study material.

### MVP Exit Criteria

MVP is complete when all of these are true:

- A new user can sign up, onboard, create a notebook, upload a syllabus plus source material, see syllabus coverage, get an editable study plan, complete one SRS session, and complete one MCQ drill on Flutter and web.
- Every generated question and card shows source provenance back to the user's material.
- MVP starts with PDFs/images and does not claim full production support for videos, PPTs, docs, spreadsheets, or every media type.
- Mains answer evaluation, coaching dashboards, community features, curated central content, and broad multi-domain scale are explicitly out of scope.
- CI is green for the existing Flutter and Quarkus workflows.
- Public beta has basic operational controls: auth, quotas, error UX, logs, and a staging smoke test.

### Epic M0: Pre-Beta Foundation

Internal gate before opening signup.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M0.1 | Student profile API | Backend | Stubbed | Existing auth | `PUT /v1/users/me/onboarding` persists study level, goal type, target date, daily minutes, learning preferences, and notification preferences for the authenticated user; `GET /v1/users/me` returns onboarding status and profile data. See `docs/superpowers/specs/2026-05-19-onboarding-execution-design.md`. | Integration test creates a Firebase-authenticated profile update and reads it back from `GET /v1/users/me`. |
| M0.2 | Notebook and syllabus model | Backend | New | M0.1 | Users can create a notebook with goal, completion date, syllabus tree, and stable topic identifiers. | API test creates a notebook and `GET /taxonomy/syllabus?notebookId=...` returns a nested tree. |
| M0.3 | Notebook material metadata | Backend | Stubbed | M0.2 | `POST /ingestion/upload` creates a notebook-scoped material/document row and returns stable material, document, and job IDs. | Upload a small PDF through HTTP and confirm the row is scoped to the notebook with `status='pending'` or `status='processing'`. |
| M0.4 | PDF text extraction and chunking | Backend | Stubbed | M0.3 | A text-based PDF produces ordered `chunks` rows linked to the uploaded document. Page metadata can be basic in MVP but must not lose document provenance. | Unit test extracts a fixture PDF and asserts non-empty chunks with deterministic sequence numbers. |
| M0.5 | Founder dogfood script | Product, QA | New | M0.2, M0.4 | A documented manual script creates one real notebook, ingests one study-material set, maps at least one topic, and generates at least ten practice items. | Run the script end to end and record screenshots or terminal output in a dogfood note. |

### Epic M1: Onboarding And Identity

Public beta entry point.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M1.1 | Flutter onboarding flow | Flutter | New | M0.1 | New authenticated users provide what they are learning, study level, target date, available minutes, preferred learning methods, and notification preference before landing on first-notebook setup or dashboard, based on backend onboarding and notebook state. | Flutter integration test covers first login through saved onboarding state. |
| M1.2 | Web onboarding flow | Web | New | M0.1 | `web/apps/web` exposes the same onboarding fields and calls the same REST API contracts as Flutter. | Browser test or manual smoke confirms a new web user can save onboarding and reload without losing data. |
| M1.3 | Notebook creation flow | Flutter, Web, Backend | New | M0.2, M1.1, M1.2 | Users can create a notebook through `POST /v1/notebooks` for a subject, course, or exam with a target completion date before uploading material. | Manual smoke creates a notebook on web and opens it on Flutter. |
| M1.4 | Empty-state dashboard | Flutter, Web | Stubbed | M1.3 | `GET /dashboard/summary` returns onboarding status, active notebook count, next action, and zero-safe metrics so users with no notebooks or uploads see clear CTAs instead of static demo metrics. | Screenshot or widget test asserts the notebook/upload CTA appears for an empty account. |
| M1.5 | Sign-out and account controls | Flutter, Web, Backend | Partially implemented | M1.1, M1.2 | Sign-out clears local session state, and account deletion or retention policy is documented in product copy. | Auth flow test signs in, signs out, and confirms protected routes redirect to login. |

### Epic M2: Ingestion And Syllabus Mapping

The user-owned material pipeline.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M2.1 | Notebook upload UI on Flutter and web | Flutter, Web | Stubbed | M0.3, M1.3 | Users can pick a PDF or image inside a notebook, start upload, see progress, and see success or failure states. | Upload a 5 MB PDF on both clients and confirm the same document appears in the backend. |
| M2.2 | Job status polling | Backend, Flutter, Web | Stubbed | M2.1 | Clients can poll ingestion status until `ready` or `failed`; failed jobs return a user-safe reason. | Force an invalid file upload and confirm the UI shows a clear, typed error. |
| M2.3 | Syllabus and bibliography mapping v0 | Backend | Planned | M0.2, M0.4 | Chunks are linked to likely syllabus items and source/bibliography references using deterministic rules, keyword mapping, or a constrained LLM prompt. | Upload a known textbook passage and confirm coverage appears under the expected syllabus branch with a source reference. |
| M2.4 | Syllabus coverage API | Backend | Stubbed | M2.3 | `GET /taxonomy/coverage` returns `not_started`, `partial`, `covered`, or `needs_revision` per syllabus item for the current notebook. | Integration test seeds chunks and asserts coverage changes from `not_started` to `partial`. |
| M2.5 | Topic workspace screens | Flutter, Web | Stubbed | M2.4 | Flutter and web show the syllabus tree, topic-level coverage, mapped source material, and clear empty states. | UI test or manual smoke confirms a mapped topic shows a non-empty coverage bar and linked source. |

### Epic M3: Generation With Provenance

MVP uses the Quarkus backend boundary and `LlmGateway` interface. The separate Java AI runtime is deferred to v2 unless production load requires earlier extraction.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M3.1 | Real LLM gateway behind interface | Backend, AI | Stubbed | M0.4 | `StubLlmGateway` is replaced or wrapped by a provider-backed implementation configured through environment variables. | Generate one MCQ from a known chunk in a local or staging environment without committing secrets. |
| M3.2 | MCQ persistence | Backend | Stubbed | M3.1 | `POST /questions/generate` persists single-correct MCQs with stem, options, correct key, explanation, difficulty, topic, and source chunk. | Contract test calls the endpoint and confirms a persisted `questions` row. |
| M3.3 | Flashcard persistence | Backend | Stubbed | M3.1 | Generated flashcards are atomic, persisted, linked to source chunks, and available to SRS. | API test generates flashcards and confirms `flashcards` plus `srs_state` rows exist. |
| M3.4 | Provenance in APIs and UI | Backend, Flutter, Web | Planned | M3.2, M3.3 | Every generated item exposes document, page or chunk reference, topic path, and generation job identifier; UI shows a source affordance. | Manual smoke opens a generated MCQ and navigates to source context. |
| M3.5 | Generation validation guardrails | Backend, AI | Planned | M3.2, M3.3 | Invalid outputs without source references, malformed MCQ options, or missing answers are rejected before persistence. | Unit tests feed invalid generated JSON and assert rejection with no database write. |
| M3.6 | Baseline validation | Backend, AI, Flutter, Web | Planned | M2.5, M3.2, M3.3 | After chunking and mapping, users answer a short random diagnostic set so the planner can estimate starting knowledge per notebook/topic. | Manual smoke completes a baseline set and confirms weak-topic signals are stored. |

### Epic M4: Practice Loop

The habit-forming product core.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M4.1 | SRS scheduler v0 | Backend | Stubbed | M3.3 | `SchedulerService` implements a simple SM-2-style update for again, hard, good, and easy ratings. | Unit tests verify `due_at`, interval, repetitions, and ease factor changes for each rating. |
| M4.2 | Due cards API | Backend | Stubbed | M4.1 | An authenticated API returns due flashcards and questions ordered by due time and scoped to the current user and notebook. | Integration test creates due and future cards and confirms only due items are returned. |
| M4.3 | Flashcard practice UI | Flutter | Stubbed | M4.2 | Flutter users can review cards, reveal answers, rate recall, and proceed to the next due item. | Manual session reviews ten cards and confirms backend review rows update. |
| M4.4 | MCQ drill UI | Flutter | Stubbed | M3.2 | Flutter users can answer untimed single-correct MCQs, see rationale, and view source. | Manual session completes ten MCQs and confirms attempt events or review state are recorded. |
| M4.5 | Web practice parity | Web | New | M4.2, M4.4 | Web users can complete the same flashcard and MCQ flows against the same REST APIs. | Cross-client smoke: start on web, review on Flutter, and confirm state remains consistent. |

### Epic M5: Daily Plan

The daily "what should I do now?" surface.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M5.1 | Adaptive study plan builder | Backend | Stubbed | M2.4, M3.6, M4.2 | `DailyPlanService` or successor planner writes plan tasks from due SRS, baseline weak areas, source coverage, timeframe, available minutes, new cards, and MCQ/PYQ sets. | Unit test creates a user with due cards, weak topics, and a target date, then asserts plan items fit the budget. |
| M5.2 | Editable study plan API | Backend | Stubbed | M5.1 | APIs return the generated plan, accept student edits, and preserve an auditable plan history. | Integration test edits a task date/minute allocation and confirms future daily plan output changes. |
| M5.3 | Daily plan API | Backend | Stubbed | M5.2 | `GET /srs/plan/today` returns today's minutes budget, ordered task list, task status, and completion state. | Integration test confirms returned plan matches `daily_minutes`, notebook scope, and user scope. |
| M5.4 | Plan UI on dashboard | Flutter, Web | Stubbed | M5.3 | Home dashboard shows today's playlist and lets the user start, edit, or mark tasks complete. | Manual smoke completes a task and confirms the dashboard updates without stale static data. |
| M5.5 | Realistic planning rules | Backend | Planned | M5.1 | The planner does not over-assign beyond daily minutes and handles empty, huge, overdue, missed-day, and edited-plan backlogs predictably. | Unit tests cover empty backlog, many overdue cards, very low daily-minute settings, and a missed day. |
| M5.6 | Mobile nudges and focus preferences | Flutter, Backend | Planned | M5.3 | The mobile app can nudge due reviews and accepted plan tasks while respecting quiet hours and opt-in notification settings. | Test device receives one due-plan reminder and no reminders during quiet hours. |

### Epic M6: PYQ MVP

Minimum previous-year-question support for public beta.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M6.1 | User PYQ ingestion | Backend | Stubbed | M2.2, M2.3 | User-uploaded PYQ or past-paper PDFs produce question records with year or source, paper/course, topic, source document, and question text. | Seed one past paper and confirm browsable PYQ rows exist. |
| M6.2 | PYQ-to-syllabus/source mapping | Backend, AI | Planned | M6.1, M2.3 | Each PYQ maps to syllabus topic and, where possible, book/page/chunk references from notebook material. | Fixture PYQ maps to an expected topic and source page with confidence metadata. |
| M6.3 | PYQ practice and mock exam API/UI | Backend, Flutter, Web | Stubbed | M6.2 | Users can filter PYQs by year/paper/topic or attend a PYQ set as a mock exam. | Manual smoke practices five PYQs and completes one mock exam session. |
| M6.4 | PYQ coverage metric | Backend, Flutter, Web | Stubbed | M6.3 | Dashboard shows the percent of syllabus topics with at least one practiced or ingested PYQ. | API test seeds PYQs across topics and confirms coverage metric changes. |

### Epic M7: Dashboard And Public-Beta Operations

Make the beta reliable enough for real users.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M7.1 | Live notebook dashboard summary | Backend, Flutter, Web | Stubbed | M2.4, M5.3, M6.4 | Static dashboard data is replaced by real aggregates: coverage, due cards, plan status, PYQ coverage, weak topics, and time spent. | Flutter and web dashboard values match `GET /dashboard/summary`. |
| M7.2 | Typed error UX | Backend, Flutter, Web | Partially implemented | M1.1 | Protected routes, validation failures, upload failures, and service errors surface typed, user-safe messages. | Force 401, 400, and 503 paths and confirm UI does not show raw stack traces or `.toString()` output. |
| M7.3 | Observability baseline | Infra, Backend | Partially implemented | M2.2, M3.5 | HTTP latency, job lifecycle, generation accept/reject counts, and error rates are exposed or logged in a structured way. | Prometheus scrape or structured log query shows metrics during upload and generation. |
| M7.4 | Rate limits and quotas | Backend, Infra | Planned | M3.1 | Public beta users have per-user upload and generation caps with clear 429 responses. | Test exceeds generation quota and receives a typed 429 error. |
| M7.5 | Privacy and deletion hooks | Backend, Product | Planned | M0.3 | Notebook or document deletion removes or tombstones related chunks, embeddings, generated items, plans, reviews, and PYQs according to documented retention policy. | Integration test deletes a document and confirms user-owned dependent rows are gone or tombstoned. |
| M7.6 | Public beta launch checklist | Product, QA, Infra | New | M7.1, M7.5 | Staging environment, Firebase production project, smoke suite, rollback notes, and beta support channel are ready. | Run CI, complete manual signup smoke on Flutter and web, and record launch checklist results. |

## v1: Beta Hardening And Depth

v1 keeps the supported notebook scope narrow but makes the product meaningfully better for retention, trust, planning quality, and PYQ/mock-exam depth.

### v1 Exit Criteria

- D1 and D7 retention are measured.
- PYQ trend analysis is visible in the product.
- Assertion-reason and match-the-following drills are available.
- Scanned PDF/image ingestion is reliable enough for common handwritten notes and textbook scans.
- Notifications can remind users about today's plan.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| V1.1 | PYQ analytics API | Backend | Stubbed | M6.4 | `GET /pyq/analytics` returns topic frequency, coverage, and hot/cold topic signals for a notebook or exam track. | Integration test seeds PYQs across years and confirms frequency output. |
| V1.2 | PYQ analytics UI | Flutter, Web | New | V1.1 | Dashboard and PYQ screens show topic frequency charts and topic-priority hints. | Manual smoke confirms analytics update after seeded PYQ data changes. |
| V1.3 | Assertion-reason questions | Backend, AI, Flutter, Web | Planned | M3.5, M4.4 | Generation, validation, persistence, and practice UI support assertion-reason items. | Unit tests validate exactly one correct answer and UI smoke completes a drill. |
| V1.4 | Match-the-following questions | Backend, AI, Flutter, Web | Planned | M3.5, M4.4 | Generation, validation, persistence, and practice UI support match-the-following items. | Unit tests reject malformed pairs and manual smoke completes a drill. |
| V1.5 | OCR provider integration | Backend, Infra | Planned | M2.2 | Scanned PDFs use an OCR fallback and surface extraction quality to the job status. | Fixture with scanned pages produces text chunks above a documented quality threshold. |
| V1.6 | Daily plan notifications | Flutter, Backend | Partially implemented | M5.6 | FCM token sync is wired to plan reminders, with user opt-in controls and quiet hours. | Test device receives a reminder for an unfinished daily plan and none during quiet hours. |
| V1.7 | Retention analytics | Flutter, Web, Backend | Partially implemented | M4.5, M5.3 | Product records key events: onboarding completed, upload completed, card reviewed, MCQ answered, plan completed, and source opened. | Analytics test or debug console shows expected event names and properties. |
| V1.8 | Offline cache for critical practice data | Flutter | Planned | M4.3 | Due cards and today's plan remain readable after short network loss. | Manual smoke loads plan online, disables network, and opens due cards. |
| V1.9 | Content review queue | Backend, Product | New | M3.5 | Bad generations can be flagged and reviewed through an internal script or admin-only route. | Flag a generated item and confirm it appears in review output with source refs. |
| V1.10 | Beta quality dashboard | Infra, Product | New | V1.7 | Founder can see active users, D1/D7, cards reviewed per week, generation rejection rate, and upload failures. | Dashboard or report updates from staging/beta events. |

## v2: AI Platform And Multimodal Expansion

v2 turns the MVP AI path into a clearer platform and expands beyond PDF/image-first notebooks.

### v2 Exit Criteria

- Java AI module handles generation or chat jobs behind explicit contracts.
- Qdrant-backed RAG is productionized with user and notebook-scope isolation tests.
- gRPC streaming shows ingestion or generation progress in Flutter.
- Richer material types such as videos, PPTs, docs, spreadsheets, or links start entering the ingestion pipeline.
- Mains-oriented short-answer prompts are part of daily planning.
- One second exam, UGC NET Computer Science or TNPSC Group, is live in beta.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| V2.1 | Java AI module runtime | AI, Backend, Infra | Planned | V1.3, V1.4 | A separate Java service accepts scoped generation jobs from Quarkus and returns structured outputs. | Contract test sends a scoped job and receives validated generated items. |
| V2.2 | Quarkus-to-AI contracts | Backend, AI | Planned | V2.1 | REST product APIs create durable jobs; AI execution happens through explicit internal contracts. | Test confirms product state is persisted in Quarkus/Postgres, not the AI module. |
| V2.3 | Qdrant indexing | Backend, AI, Infra | Configured | M2.4 | Chunks are embedded and indexed with user, notebook, exam, topic, document, page, and timestamp payload filters. | Integration test searches as user A and confirms user B chunks are not returned. |
| V2.4 | RAG generation | AI, Backend | Planned | V2.1, V2.3 | Generation uses filtered retrieval, prompt templates, output validation, and source metadata. | Fixture generation includes only allowed source references. |
| V2.5 | gRPC job streaming | Backend, Flutter | Stubbed | V2.2 | Flutter can subscribe to ingestion and generation job progress with stable phases. | Manual smoke uploads a large PDF and sees progress updates without page refresh. |
| V2.6 | Chat over material | AI, Backend, Flutter, Web | Planned | V2.4, V2.5 | Users can ask source-grounded questions over their uploaded material; answers cite chunks/pages. | Chat smoke asks about a known PDF passage and opens cited source. |
| V2.7 | Mains writing prompts | Backend, AI, Flutter, Web | Planned | V2.4 | Daily plan can include short-answer prompts using directive verbs like discuss, evaluate, and critically examine. | Manual smoke completes one writing prompt; no automatic score is shown. |
| V2.8 | Rich material ingestion | Backend, AI, Infra | Planned | V2.3 | At least one non-PDF/image material type, such as video transcript, PPT, docs, spreadsheet, or link ingestion, produces notebook-scoped chunks. | Upload the selected material type and confirm mapped chunks appear in a topic workspace. |
| V2.9 | Second exam taxonomy | Backend, Product | Planned | V2.3 | Either UGC NET Computer Science or TNPSC Group taxonomy is seeded and selectable in onboarding. | New user selects second exam and sees correct syllabus tree. |
| V2.10 | Second exam generation templates | AI, Backend | Planned | V2.9 | Generation templates and validators match the chosen second exam's question patterns. | Generate ten questions for the second exam and pass validator tests. |
| V2.11 | Curated PYQ corpus | Backend, Product | Planned | V2.9 | Shared PYQ data is separated from user-owned corpora and available for practice where licensing permits. | User can practice curated PYQs without uploading a PDF; deletion of user material does not affect curated content. |

## v3: Learning Operating System

v3 expands Preppy into a platform while keeping user-owned material, structured curricula, and plan-aware learning at the center.

### v3 Exit Criteria

- At least three major learning domains or exam tracks are production-ready.
- Personalization demonstrably improves plan completion or practice quality.
- One B2B coaching pilot is running.
- Mains evaluation, if shipped, has a human-in-the-loop or clear reliability disclaimer.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| V3.1 | Multi-domain configuration model | Backend, Product | Planned | V2.9 | Subject, course, and exam-specific taxonomy, templates, scoring rules, and planner rules are config-driven enough to add a third domain without bespoke rewrites. | Add a third domain in staging and complete onboarding plus syllabus browsing. |
| V3.2 | Advanced personalization | Backend, AI | Planned | V2.7 | Planner uses performance, coverage, PYQ frequency, recency, target date, and observed learning pace to prioritize tasks. | A/B or cohort report shows better plan completion or weak-topic improvement. |
| V3.3 | Notebook readiness model | Backend, Product | Planned | V3.2 | Dashboard estimates readiness by notebook/topic using coverage, review performance, baseline progress, and PYQ exposure. | Fixture user with weak topics receives lower readiness for those topics. |
| V3.4 | Mains evaluation lite | AI, Backend, Flutter, Web | Planned | V2.7 | Users can submit answers for rubric-based feedback with source-grounded suggestions and reliability disclaimers. | Sample answer receives rubric feedback; unsupported claims are flagged rather than hallucinated. |
| V3.5 | Coaching workspace | Backend, Web, Product | Planned | V3.1 | Teacher or mentor users can review learner progress, assigned topics, and flagged answers with explicit consent. | Pilot coach account views only assigned learner data. |
| V3.6 | Advanced planning integrations | Backend, Flutter, Web | Planned | V3.2 | Calendar exports, mock-test scheduling, and weekly plan views are available. | Exported calendar events match daily plan tasks and target dates. |
| V3.7 | Optional community experiment | Product, Web | Planned | V3.5 | Community features are tested only if beta users ask for peer workflows; default scope remains private study. | Experiment report shows whether community improves retention without distracting from practice. |

## Cross-Cutting Quality Gates

These gates apply to every milestone.

| Gate | Requirement | Verify |
| --- | --- | --- |
| Contract quality | REST endpoints use typed DTOs, validation annotations, and OpenAPI documentation. Breaking changes are versioned. | OpenAPI document includes new endpoints and CI/integration tests cover them. |
| Security | Every product record is scoped by internal user ID derived from Firebase auth. Clients cannot choose another user's notebook, document, job, or Qdrant filter scope. | Cross-user access tests fail with 403 or 404. |
| Provenance | Generated artifacts cannot be persisted without source references to document, chunk, topic, and generation job where applicable. | Validator tests reject missing or cross-user source refs. |
| Planning integrity | Generated plans preserve student edits, fit available minutes, and recover predictably from missed days. | Planner tests cover edited plans, missed days, and low-availability schedules. |
| Privacy | Logs do not include raw PDF text, full prompts, full model outputs, service-account secrets, or user document content. | Log review during upload/generation smoke. |
| Reliability | Long-running work has durable job records, safe retry behavior, and user-visible failure states. | Restart backend during a job in staging and confirm status is recoverable or clearly failed. |
| Flutter state | Full screens use typed screen states and a single screen provider; raw `AsyncValue` matching is limited to small sub-widgets. | Code review against `.cursor/rules/state-architecture.mdc`. |
| Web forms | Web forms use `react-hook-form`, `zod`, and existing shadcn form primitives where forms are added. | Code review and lint. |
| Theme | UI uses theme tokens rather than hard-coded color literals. | Code review and lint/style checks. |
| CI | Existing Flutter and Quarkus workflows pass before release. | Run GitHub Actions or local equivalents. |
| Documentation | README, ABOUT, TECHNICAL, and ROADMAP stay consistent when milestone scope changes. | Documentation review before milestone branch merges. |

## Dependency Graph

```text
Auth/Profile -> Onboarding -> Notebook -> Upload -> Chunking -> Syllabus Mapping -> Coverage
                                                       |                              |
                                                       v                              v
                                             Baseline Validation -> Generation -> SRS -> Study Plan -> Dashboard
                                                       |                         |
                                                       v                         v
                                                     PYQ --------------------> Practice
```

## Out Of Scope By Milestone

| Milestone | Explicitly out of scope |
| --- | --- |
| MVP | Mains answer evaluation, coaching dashboards, social/community features, multiple production exam tracks, curated central content, production Java AI module, production gRPC streaming, full video/PPT/doc/spreadsheet extraction. |
| v1 | Full multi-domain platform, B2B coaching, automatic Mains scoring, large curated content marketplace. |
| v2 | Fully reliable Mains evaluation, broad community features, coaching SaaS, unrestricted public content sharing. |
| v3 | Anything that weakens the private, plan-focused practice loop without evidence from users. |

## Open Decisions

| Decision | Needed by | Current recommendation |
| --- | --- | --- |
| OCR provider | v1 | Start with the simplest provider that handles common coaching-note scans; measure extraction quality before optimizing. |
| Rich material priority | v2 | Pick the next format after PDFs/images based on real notebook uploads, likely video transcript, PPT, docs, or spreadsheets. |
| Object storage provider | MVP | Use a production object store before public beta; keep Postgres for metadata only. |
| Embedding model and dimensions | v2 | Choose when Qdrant indexing starts; avoid locking MVP to an embedding model unless RAG is pulled forward. |
| Managed vs self-hosted Qdrant | v2 | Keep local Docker for development; decide production hosting based on expected beta volume. |
| Second exam | v2 | Pick UGC NET Computer Science or TNPSC Group after MVP usage shows which audience is stronger. |
| Web app location | MVP | Extend `web/apps/web` first. Create a new web app only if product and docs concerns become tangled. |
| Java AI framework | v2 | Choose LangChain4j or equivalent when extracting the AI module, not during MVP. |
| Retention policy | MVP | Define document deletion behavior before public beta launch. |
| Quota model | MVP | Start with conservative upload and generation caps; revisit after usage data. |
| Planner recovery policy | MVP | Define how missed tasks, student edits, and quiet hours affect regenerated plans. |

## Release Checklist Template

Use this checklist for every milestone release.

- Scope matches this roadmap and any linked issue tracker.
- All deliverables in the milestone have a recorded verification result.
- User-owned data is scoped and deletion behavior is understood.
- Generated content has source provenance.
- Study plans fit available time and preserve student edits.
- Flutter and web user paths are tested where both clients are in scope.
- OpenAPI is current for backend API changes.
- CI is green.
- Known limitations are documented in release notes or product copy.
- Rollback or disablement path exists for expensive AI features.

