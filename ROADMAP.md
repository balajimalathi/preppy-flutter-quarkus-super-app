# Preppy Roadmap

Preppy is a personal exam autopilot for serious UPSC, NET, and TNPSC aspirants. It turns a user's own PDFs, notes, syllabi, and previous-year questions into an exam-aware workflow for coverage, practice, spaced repetition, PYQ analysis, and daily planning.

This roadmap translates the product direction in [ABOUT.md](ABOUT.md) and the architecture in [TECHNICAL.md](TECHNICAL.md) into testable, deliverable milestones.

## How To Read This Roadmap

### Milestone Definitions

| Milestone | Meaning | Release bar |
| --- | --- | --- |
| MVP | Public beta | Anyone can sign up, complete onboarding, upload material, generate practice items, and complete the core daily practice loop on Flutter and web. |
| v1 | Beta hardening and product depth | The beta is reliable, measurable, and deeper for UPSC CSE GS + Prelims, with PYQ analytics, better question formats, notifications, and retention instrumentation. |
| v2 | AI platform and exam expansion | AI execution moves behind clearer runtime boundaries, streaming experiences are live, Mains-oriented practice starts, and one second exam is added. |
| v3 | Exam operating system | Preppy becomes a multi-exam platform with advanced personalization, B2B coaching workflows, and optional community features only if validated. |

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

Preppy should feel like an exam operating system for a serious aspirant: bring your own syllabus, PDFs, notes, and PYQs; Preppy maps them to the exam, generates source-grounded practice, schedules revision, and tells you what to do today. The product wins by being exam-aware and provenance-first, not by being another generic PDF chatbot.

## Milestone Overview

```mermaid
flowchart LR
  subgraph mvp [MVP Public Beta]
    Onboard[Onboarding]
    Ingest[Ingestion]
    Gen[Generation]
    Practice[Practice Loop]
    Dash[Dashboard]
  end
  subgraph v1 [v1 Depth]
    PyqUI[PYQ Analytics UI]
    Formats[Question Formats]
    Ops[Ops and Retention]
  end
  subgraph v2 [v2 AI and Exams]
    AiMod[Java AI Module]
    Streams[gRPC Streams]
    Mains[Mains Practice]
    Exam2[Second Exam]
  end
  subgraph v3 [v3 Platform]
    B2B[Coaching B2B]
    Personalize[Personalization]
    MultiExam[Multi Exam OS]
  end
  mvp --> v1 --> v2 --> v3
```

## MVP: Public Beta

MVP is intentionally larger than an internal alpha because the release bar is public beta. The first gate is still internal dogfood, so the product does not open signup before the core loop works on real study material.

### MVP Exit Criteria

MVP is complete when all of these are true:

- A new user can sign up, onboard, upload a PDF, see syllabus coverage, get today's plan, complete one SRS session, and complete one MCQ drill on Flutter and web.
- Every generated question and card shows source provenance back to the user's material.
- UPSC CSE GS + Prelims is the only supported production exam.
- Mains answer evaluation, coaching dashboards, community features, curated central content, and multi-exam scale are explicitly out of scope.
- CI is green for the existing Flutter and Quarkus workflows.
- Public beta has basic operational controls: auth, quotas, error UX, logs, and a staging smoke test.

### Epic M0: Pre-Beta Foundation

Internal gate before opening signup.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M0.1 | Exam profile API | Backend | Stubbed | Existing auth | A protected endpoint persists exam, target date, daily minutes, and selected papers for the authenticated user. | Integration test creates a Firebase-authenticated profile update and reads it back from `GET /v1/users/me` or the chosen profile endpoint. |
| M0.2 | UPSC taxonomy seed | Backend | New | M0.1 | Flyway seeds UPSC CSE GS + Prelims into `syllabus_items` with stable codes and parent-child hierarchy. | `GET /taxonomy/syllabus?exam=UPSC_CSE` returns a nested tree with GS and Prelims roots. |
| M0.3 | Document upload metadata | Backend | Stubbed | Existing auth | `POST /ingestion/upload` creates an `ingested_docs` row, scopes it to the user, and returns a stable document ID and job ID. | Upload a small PDF through HTTP and confirm the row exists with `status='pending'` or `status='processing'`. |
| M0.4 | PDF text extraction and chunking | Backend | Stubbed | M0.3 | A text-based PDF produces ordered `chunks` rows linked to the uploaded document. Page metadata can be basic in MVP but must not lose document provenance. | Unit test extracts a fixture PDF and asserts non-empty chunks with deterministic sequence numbers. |
| M0.5 | Founder dogfood script | Product, QA | New | M0.2, M0.4 | A documented manual script ingests one real study-material set, maps at least one topic, and generates at least ten practice items. | Run the script end to end and record screenshots or terminal output in a dogfood note. |

### Epic M1: Onboarding And Identity

Public beta entry point.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M1.1 | Flutter onboarding flow | Flutter | New | M0.1 | New authenticated users select exam, target date, daily minutes, and selected papers before landing on dashboard. | Flutter integration test covers first login through saved onboarding state. |
| M1.2 | Web onboarding flow | Web | New | M0.1 | `web/apps/web` exposes the same onboarding fields and calls the same REST API contracts as Flutter. | Browser test or manual smoke confirms a new web user can save onboarding and reload without losing data. |
| M1.3 | Empty-state dashboard | Flutter, Web | Stubbed | M1.1, M1.2 | Users with no uploads see a clear dashboard CTA to upload their first PDF instead of static demo metrics. | Screenshot or widget test asserts the upload CTA appears for an empty account. |
| M1.4 | Sign-out and account controls | Flutter, Web, Backend | Partially implemented | M1.1, M1.2 | Sign-out clears local session state, and account deletion or retention policy is documented in product copy. | Auth flow test signs in, signs out, and confirms protected routes redirect to login. |

### Epic M2: Ingestion And Syllabus Mapping

The user-owned material pipeline.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M2.1 | Upload UI on Flutter and web | Flutter, Web | Stubbed | M0.3 | Users can pick a PDF, start upload, see progress, and see success or failure states. | Upload a 5 MB PDF on both clients and confirm the same document appears in the backend. |
| M2.2 | Job status polling | Backend, Flutter, Web | Stubbed | M2.1 | Clients can poll ingestion status until `ready` or `failed`; failed jobs return a user-safe reason. | Force an invalid file upload and confirm the UI shows a clear, typed error. |
| M2.3 | Topic classification v0 | Backend | Planned | M0.2, M0.4 | Chunks are linked to likely syllabus items using deterministic rules, keyword mapping, or a constrained LLM prompt. | Upload a known Modern History passage and confirm coverage appears under the expected syllabus branch. |
| M2.4 | Syllabus coverage API | Backend | Stubbed | M2.3 | `GET /taxonomy/coverage` returns `not_started`, `partial`, `covered`, or `needs_revision` per syllabus item for the current user. | Integration test seeds chunks and asserts coverage changes from `not_started` to `partial`. |
| M2.5 | Syllabus coverage screens | Flutter, Web | Stubbed | M2.4 | Flutter and web show the syllabus tree with topic-level coverage and clear empty states. | UI test or manual smoke confirms a mapped topic shows a non-empty coverage bar. |

### Epic M3: Generation With Provenance

MVP uses the Quarkus backend boundary and `LlmGateway` interface. The separate Java AI runtime is deferred to v2 unless production load requires earlier extraction.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M3.1 | Real LLM gateway behind interface | Backend, AI | Stubbed | M0.4 | `StubLlmGateway` is replaced or wrapped by a provider-backed implementation configured through environment variables. | Generate one MCQ from a known chunk in a local or staging environment without committing secrets. |
| M3.2 | MCQ persistence | Backend | Stubbed | M3.1 | `POST /questions/generate` persists single-correct MCQs with stem, options, correct key, explanation, difficulty, topic, and source chunk. | Contract test calls the endpoint and confirms a persisted `questions` row. |
| M3.3 | Flashcard persistence | Backend | Stubbed | M3.1 | Generated flashcards are atomic, persisted, linked to source chunks, and available to SRS. | API test generates flashcards and confirms `flashcards` plus `srs_state` rows exist. |
| M3.4 | Provenance in APIs and UI | Backend, Flutter, Web | Planned | M3.2, M3.3 | Every generated item exposes document, page or chunk reference, topic path, and generation job identifier; UI shows a source affordance. | Manual smoke opens a generated MCQ and navigates to source context. |
| M3.5 | Generation validation guardrails | Backend, AI | Planned | M3.2, M3.3 | Invalid outputs without source references, malformed MCQ options, or missing answers are rejected before persistence. | Unit tests feed invalid generated JSON and assert rejection with no database write. |

### Epic M4: Practice Loop

The habit-forming product core.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M4.1 | SRS scheduler v0 | Backend | Stubbed | M3.3 | `SchedulerService` implements a simple SM-2-style update for again, hard, good, and easy ratings. | Unit tests verify `due_at`, interval, repetitions, and ease factor changes for each rating. |
| M4.2 | Due cards API | Backend | Stubbed | M4.1 | An authenticated API returns due flashcards and questions ordered by due time and scoped to the current user. | Integration test creates due and future cards and confirms only due items are returned. |
| M4.3 | Flashcard practice UI | Flutter | Stubbed | M4.2 | Flutter users can review cards, reveal answers, rate recall, and proceed to the next due item. | Manual session reviews ten cards and confirms backend review rows update. |
| M4.4 | MCQ drill UI | Flutter | Stubbed | M3.2 | Flutter users can answer untimed single-correct MCQs, see rationale, and view source. | Manual session completes ten MCQs and confirms attempt events or review state are recorded. |
| M4.5 | Web practice parity | Web | New | M4.2, M4.4 | Web users can complete the same flashcard and MCQ flows against the same REST APIs. | Cross-client smoke: start on web, review on Flutter, and confirm state remains consistent. |

### Epic M5: Daily Plan

The daily "what should I do now?" surface.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M5.1 | Daily plan builder | Backend | Stubbed | M2.4, M4.2 | `DailyPlanService` writes `daily_plans.items` from due SRS, new cards, weak or uncovered topics, and a small MCQ or PYQ set. | Unit test creates a user with due cards and uncovered topics, then asserts plan items fit the budget. |
| M5.2 | Daily plan API | Backend | Stubbed | M5.1 | `GET /srs/plan/today` returns today's minutes budget, ordered task list, task status, and completion state. | Integration test confirms returned plan matches `daily_minutes` and user scope. |
| M5.3 | Plan UI on dashboard | Flutter, Web | Stubbed | M5.2 | Home dashboard shows today's playlist and lets the user start or mark tasks complete. | Manual smoke completes a task and confirms the dashboard updates without stale static data. |
| M5.4 | Realistic planning rules | Backend | Planned | M5.1 | The planner does not over-assign beyond daily minutes and handles empty, huge, and overdue backlogs predictably. | Unit tests cover empty backlog, many overdue cards, and very low daily-minute settings. |

### Epic M6: PYQ MVP

Minimum previous-year-question support for public beta.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M6.1 | User PYQ ingestion | Backend | Stubbed | M2.2, M2.3 | User-uploaded PYQ PDFs produce PYQ question records with year, paper, topic, source document, and question text. | Seed one UPSC GS paper and confirm browsable PYQ rows exist. |
| M6.2 | PYQ practice API and UI | Backend, Flutter, Web | Stubbed | M6.1 | Users can filter PYQs by year, paper, and topic, then practice a small set. | Manual smoke practices five PYQs and confirms topic filters work. |
| M6.3 | PYQ coverage metric | Backend, Flutter, Web | Stubbed | M6.2 | Dashboard shows the percent of syllabus topics with at least one practiced or ingested PYQ. | API test seeds PYQs across topics and confirms coverage metric changes. |

### Epic M7: Dashboard And Public-Beta Operations

Make the beta reliable enough for real users.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| M7.1 | Live dashboard summary | Backend, Flutter, Web | Stubbed | M2.4, M5.2, M6.3 | Static dashboard data is replaced by real aggregates: coverage, due cards, plan status, PYQ coverage, and time spent. | Flutter and web dashboard values match `GET /dashboard/summary`. |
| M7.2 | Typed error UX | Backend, Flutter, Web | Partially implemented | M1.1 | Protected routes, validation failures, upload failures, and service errors surface typed, user-safe messages. | Force 401, 400, and 503 paths and confirm UI does not show raw stack traces or `.toString()` output. |
| M7.3 | Observability baseline | Infra, Backend | Partially implemented | M2.2, M3.5 | HTTP latency, job lifecycle, generation accept/reject counts, and error rates are exposed or logged in a structured way. | Prometheus scrape or structured log query shows metrics during upload and generation. |
| M7.4 | Rate limits and quotas | Backend, Infra | Planned | M3.1 | Public beta users have per-user upload and generation caps with clear 429 responses. | Test exceeds generation quota and receives a typed 429 error. |
| M7.5 | Privacy and deletion hooks | Backend, Product | Planned | M0.3 | Document deletion removes or tombstones related chunks, embeddings, generated items, and PYQs according to documented retention policy. | Integration test deletes a document and confirms user-owned dependent rows are gone or tombstoned. |
| M7.6 | Public beta launch checklist | Product, QA, Infra | New | M7.1, M7.5 | Staging environment, Firebase production project, smoke suite, rollback notes, and beta support channel are ready. | Run CI, complete manual signup smoke on Flutter and web, and record launch checklist results. |

## v1: Beta Hardening And Depth

v1 keeps the exam scope narrow but makes the product meaningfully better for retention, trust, and UPSC depth.

### v1 Exit Criteria

- D1 and D7 retention are measured.
- PYQ trend analysis is visible in the product.
- Assertion-reason and match-the-following drills are available.
- Scanned PDF ingestion is reliable enough for common coaching notes.
- Notifications can remind users about today's plan.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| V1.1 | PYQ analytics API | Backend | Stubbed | M6.3 | `GET /pyq/analytics` returns topic frequency, coverage, and hot/cold topic signals for UPSC GS + Prelims. | Integration test seeds PYQs across years and confirms frequency output. |
| V1.2 | PYQ analytics UI | Flutter, Web | New | V1.1 | Dashboard and PYQ screens show topic frequency charts and topic-priority hints. | Manual smoke confirms analytics update after seeded PYQ data changes. |
| V1.3 | Assertion-reason questions | Backend, AI, Flutter, Web | Planned | M3.5, M4.4 | Generation, validation, persistence, and practice UI support assertion-reason items. | Unit tests validate exactly one correct answer and UI smoke completes a drill. |
| V1.4 | Match-the-following questions | Backend, AI, Flutter, Web | Planned | M3.5, M4.4 | Generation, validation, persistence, and practice UI support match-the-following items. | Unit tests reject malformed pairs and manual smoke completes a drill. |
| V1.5 | OCR provider integration | Backend, Infra | Planned | M2.2 | Scanned PDFs use an OCR fallback and surface extraction quality to the job status. | Fixture with scanned pages produces text chunks above a documented quality threshold. |
| V1.6 | Daily plan notifications | Flutter, Backend | Partially implemented | M5.2 | FCM token sync is wired to plan reminders, with user opt-in controls. | Test device receives a reminder for an unfinished daily plan. |
| V1.7 | Retention analytics | Flutter, Web, Backend | Partially implemented | M4.5, M5.3 | Product records key events: onboarding completed, upload completed, card reviewed, MCQ answered, plan completed, and source opened. | Analytics test or debug console shows expected event names and properties. |
| V1.8 | Offline cache for critical practice data | Flutter | Planned | M4.3 | Due cards and today's plan remain readable after short network loss. | Manual smoke loads plan online, disables network, and opens due cards. |
| V1.9 | Content review queue | Backend, Product | New | M3.5 | Bad generations can be flagged and reviewed through an internal script or admin-only route. | Flag a generated item and confirm it appears in review output with source refs. |
| V1.10 | Beta quality dashboard | Infra, Product | New | V1.7 | Founder can see active users, D1/D7, cards reviewed per week, generation rejection rate, and upload failures. | Dashboard or report updates from staging/beta events. |

## v2: AI Platform And Exam Expansion

v2 turns the MVP AI path into a clearer platform and expands beyond Prelims-style practice.

### v2 Exit Criteria

- Java AI module handles generation or chat jobs behind explicit contracts.
- Qdrant-backed RAG is productionized with user-scope isolation tests.
- gRPC streaming shows ingestion or generation progress in Flutter.
- Mains-oriented short-answer prompts are part of daily planning.
- One second exam, UGC NET Computer Science or TNPSC Group, is live in beta.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| V2.1 | Java AI module runtime | AI, Backend, Infra | Planned | V1.3, V1.4 | A separate Java service accepts scoped generation jobs from Quarkus and returns structured outputs. | Contract test sends a scoped job and receives validated generated items. |
| V2.2 | Quarkus-to-AI contracts | Backend, AI | Planned | V2.1 | REST product APIs create durable jobs; AI execution happens through explicit internal contracts. | Test confirms product state is persisted in Quarkus/Postgres, not the AI module. |
| V2.3 | Qdrant indexing | Backend, AI, Infra | Configured | M2.4 | Chunks are embedded and indexed with user, exam, topic, document, and page payload filters. | Integration test searches as user A and confirms user B chunks are not returned. |
| V2.4 | RAG generation | AI, Backend | Planned | V2.1, V2.3 | Generation uses filtered retrieval, prompt templates, output validation, and source metadata. | Fixture generation includes only allowed source references. |
| V2.5 | gRPC job streaming | Backend, Flutter | Stubbed | V2.2 | Flutter can subscribe to ingestion and generation job progress with stable phases. | Manual smoke uploads a large PDF and sees progress updates without page refresh. |
| V2.6 | Chat over material | AI, Backend, Flutter, Web | Planned | V2.4, V2.5 | Users can ask source-grounded questions over their uploaded material; answers cite chunks/pages. | Chat smoke asks about a known PDF passage and opens cited source. |
| V2.7 | Mains writing prompts | Backend, AI, Flutter, Web | Planned | V2.4 | Daily plan can include short-answer prompts using directive verbs like discuss, evaluate, and critically examine. | Manual smoke completes one writing prompt; no automatic score is shown. |
| V2.8 | Second exam taxonomy | Backend, Product | Planned | V2.3 | Either UGC NET Computer Science or TNPSC Group taxonomy is seeded and selectable in onboarding. | New user selects second exam and sees correct syllabus tree. |
| V2.9 | Second exam generation templates | AI, Backend | Planned | V2.8 | Generation templates and validators match the chosen second exam's question patterns. | Generate ten questions for the second exam and pass validator tests. |
| V2.10 | Curated PYQ corpus | Backend, Product | Planned | V2.8 | Shared PYQ data is separated from user-owned corpora and available for practice where licensing permits. | User can practice curated PYQs without uploading a PDF; deletion of user material does not affect curated content. |

## v3: Exam Operating System

v3 expands Preppy into a platform while keeping user-owned material and exam-aware planning at the center.

### v3 Exit Criteria

- At least three exams are production-ready.
- Personalization demonstrably improves plan completion or practice quality.
- One B2B coaching pilot is running.
- Mains evaluation, if shipped, has a human-in-the-loop or clear reliability disclaimer.

| ID | Deliverable | Owner | Status | Depends on | Done when | Verify |
| --- | --- | --- | --- | --- | --- | --- |
| V3.1 | Multi-exam configuration model | Backend, Product | Planned | V2.8 | Exam-specific taxonomy, templates, scoring rules, and planner rules are config-driven enough to add a third exam without bespoke rewrites. | Add a third exam in staging and complete onboarding plus syllabus browsing. |
| V3.2 | Advanced personalization | Backend, AI | Planned | V2.7 | Planner uses performance, coverage, PYQ frequency, recency, and exam date to prioritize tasks. | A/B or cohort report shows better plan completion or weak-topic improvement. |
| V3.3 | Exam readiness model | Backend, Product | Planned | V3.2 | Dashboard estimates readiness by paper/topic using coverage, review performance, and PYQ exposure. | Fixture user with weak topics receives lower readiness for those topics. |
| V3.4 | Mains evaluation lite | AI, Backend, Flutter, Web | Planned | V2.7 | Users can submit answers for rubric-based feedback with source-grounded suggestions and reliability disclaimers. | Sample answer receives rubric feedback; unsupported claims are flagged rather than hallucinated. |
| V3.5 | Coaching workspace | Backend, Web, Product | Planned | V3.1 | Teacher or mentor users can review learner progress, assigned topics, and flagged answers with explicit consent. | Pilot coach account views only assigned learner data. |
| V3.6 | Advanced planning integrations | Backend, Flutter, Web | Planned | V3.2 | Calendar exports, mock-test scheduling, and weekly plan views are available. | Exported calendar events match daily plan tasks and target dates. |
| V3.7 | Optional community experiment | Product, Web | Planned | V3.5 | Community features are tested only if beta users ask for peer workflows; default scope remains private study. | Experiment report shows whether community improves retention without distracting from practice. |

## Cross-Cutting Quality Gates

These gates apply to every milestone.

| Gate | Requirement | Verify |
| --- | --- | --- |
| Contract quality | REST endpoints use typed DTOs, validation annotations, and OpenAPI documentation. Breaking changes are versioned. | OpenAPI document includes new endpoints and CI/integration tests cover them. |
| Security | Every product record is scoped by internal user ID derived from Firebase auth. Clients cannot choose another user's document, job, or Qdrant filter scope. | Cross-user access tests fail with 403 or 404. |
| Provenance | Generated artifacts cannot be persisted without source references to document, chunk, topic, and generation job where applicable. | Validator tests reject missing or cross-user source refs. |
| Privacy | Logs do not include raw PDF text, full prompts, full model outputs, service-account secrets, or user document content. | Log review during upload/generation smoke. |
| Reliability | Long-running work has durable job records, safe retry behavior, and user-visible failure states. | Restart backend during a job in staging and confirm status is recoverable or clearly failed. |
| Flutter state | Full screens use typed screen states and a single screen provider; raw `AsyncValue` matching is limited to small sub-widgets. | Code review against `.cursor/rules/state-architecture.mdc`. |
| Web forms | Web forms use `react-hook-form`, `zod`, and existing shadcn form primitives where forms are added. | Code review and lint. |
| Theme | UI uses theme tokens rather than hard-coded color literals. | Code review and lint/style checks. |
| CI | Existing Flutter and Quarkus workflows pass before release. | Run GitHub Actions or local equivalents. |
| Documentation | README, ABOUT, TECHNICAL, and ROADMAP stay consistent when milestone scope changes. | Documentation review before milestone branch merges. |

## Dependency Graph

```text
Auth/Profile -> Onboarding -> Upload -> Chunking -> Taxonomy Mapping -> Coverage
                                             |                         |
                                             v                         v
                                      Generation -> SRS -> Daily Plan -> Dashboard
                                             |              |
                                             v              v
                                           PYQ ----------> Practice
```

## Out Of Scope By Milestone

| Milestone | Explicitly out of scope |
| --- | --- |
| MVP | Mains answer evaluation, coaching dashboards, social/community features, multiple exams, curated central content, production Java AI module, production gRPC streaming. |
| v1 | Full multi-exam platform, B2B coaching, automatic Mains scoring, large curated content marketplace. |
| v2 | Fully reliable Mains evaluation, broad community features, coaching SaaS, unrestricted public content sharing. |
| v3 | Anything that weakens the private, exam-focused practice loop without evidence from users. |

## Open Decisions

| Decision | Needed by | Current recommendation |
| --- | --- | --- |
| OCR provider | v1 | Start with the simplest provider that handles common coaching-note scans; measure extraction quality before optimizing. |
| Object storage provider | MVP | Use a production object store before public beta; keep Postgres for metadata only. |
| Embedding model and dimensions | v2 | Choose when Qdrant indexing starts; avoid locking MVP to an embedding model unless RAG is pulled forward. |
| Managed vs self-hosted Qdrant | v2 | Keep local Docker for development; decide production hosting based on expected beta volume. |
| Second exam | v2 | Pick UGC NET Computer Science or TNPSC Group after MVP usage shows which audience is stronger. |
| Web app location | MVP | Extend `web/apps/web` first. Create a new web app only if product and docs concerns become tangled. |
| Java AI framework | v2 | Choose LangChain4j or equivalent when extracting the AI module, not during MVP. |
| Retention policy | MVP | Define document deletion behavior before public beta launch. |
| Quota model | MVP | Start with conservative upload and generation caps; revisit after usage data. |

## Release Checklist Template

Use this checklist for every milestone release.

- Scope matches this roadmap and any linked issue tracker.
- All deliverables in the milestone have a recorded verification result.
- User-owned data is scoped and deletion behavior is understood.
- Generated content has source provenance.
- Flutter and web user paths are tested where both clients are in scope.
- OpenAPI is current for backend API changes.
- CI is green.
- Known limitations are documented in release notes or product copy.
- Rollback or disablement path exists for expensive AI features.

