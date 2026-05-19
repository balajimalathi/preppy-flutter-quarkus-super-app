# Preppy – Exam Autopilot v1 Product Plan and PM Review

## Executive summary

Preppy is an exam‑specific autopilot for UPSC/NET/TNPSC built around a simple promise: "bring your own PDFs and PYQs, get a full exam prep pipeline out the other side."[1] It competes not with generic "AI over documents" tools but with serious exam platforms by tying ingestion, question generation, spaced repetition, and PYQ analytics into one loop.

The v1 thesis is narrow but powerful: start with a backend "exam brain" that understands exam structures, maps user material to syllabus topics, auto‑generates questions and flashcards with provenance, and drives a daily plan tuned to the exam date and user availability.[1] The UI should remain minimal: a sharp practice surface (flashcards, MCQs, PYQs) and a single dashboard for coverage and time.

## Market and competitive reality

The generic AI study tools (e.g., NotebookLM, "AI + PDFs" apps) already offer summaries, notes, quizzes, and flashcards from uploaded documents, so "upload PDF → get MCQs" is now commodity functionality.[1] Dedicated AI flashcard/SRS tools similarly take arbitrary notes or PDFs and produce flashcards with adaptive schedules and exam‑date‑aware plans.

In the exam‑prep vertical, there are already AI‑powered UPSC/TNPSC products: platforms like SothanAI, Learnpro AI, UPSC.ai, and ExamPad provide large question banks, years of PYQs, AI explanations, adaptive drills, study plans, and model answers.[1] These tools demonstrate clear demand for AI‑enhanced prep, but they are optimized around centralized content rather than deep integration with a single student's messy personal material.

The key gap is a tool that treats the aspirant's own PDFs, notes, and PYQs as the primary asset and wraps them into an exam‑aware, long‑horizon pipeline from syllabus coverage to daily practice.[1] Preppy fills this by specializing in UPSC/NET/TNPSC structures and using user‑provided content as the default source of truth.

## Product thesis and positioning

Core thesis: "A personal exam autopilot that ingests your syllabus, PDFs, and PYQs, understands the exam you are writing, and then runs your prep for you: questions, spaced repetition, daily plans, and PYQ‑aware focus."[1] This is a workflow product more than a content product.

Positioning relative to existing categories:
- Versus NotebookLM: deeper exam modeling, scheduling, syllabus tracking, and PYQ trends, at the cost of being narrower in domain.[1]
- Versus generic AI flashcard/SRS tools: Preppy knows about Prelims/Mains, negative marking, GS papers, optionals, and directive verbs; it is not "just" recall optimization.[1]
- Versus UPSC.ai/SothanAI/ExamPad: BYO material is first‑class; Preppy does not try to replace coaching notes or books but to operationalize them.

The strategic moat is the exam‑specific modeling (taxonomies, question templates, directives, scoring logic) plus long‑term user data (performance, coverage, and time) that drives personalization and PYQ‑aware recommendations.[1] Over time, this can evolve into a serious "exam operating system" rather than another AI chatbot.

## Target user and initial scope

Primary initial user:
- Serious self‑studying aspirant for UPSC CSE, UGC NET Computer Science, or TNPSC Group exams, already drowning in PDFs/coaching material but lacking structure.
- Comfortable with web apps and mobile, often revising late at night, and willing to upload personal notes and PYQ collections.

Secondary early adopter:
- Tech‑savvy aspirant who already uses tools like Anki, Obsidian, or Notion and is looking for an exam‑specific layer on top of them.

Scope constraints for v1:
- Only UPSC CSE (GS1–4 + Prelims) and one state/NET variant in the first 3–6 months.
- No coaching‑style lectures, live classes, or full community features.
- No attempt at full answer‑evaluation reliability; Mains answer evaluation remains a later milestone.

## Core modules in v1

### Input and modeling layer

Function:
- Ingest PDFs (syllabus, notes, books, PYQs) into a normalized corpus with document IDs, page references, and chunked text segments.[1]
- Classify chunks into an exam‑aware taxonomy: exam → paper → subject → topic → sub‑topic.[2]

Key behaviors:
- OCR for scanned PDFs, at least good enough for NCERT scans and coaching notes.
- Persistent mapping between syllabus bullets and material coverage: for each bullet, how many pages/sections in the corpus map here, and what is their quality.
- Simple metrics: 0/partial/full coverage for each syllabus item, and total pages/sections per topic.

Why it matters:
- This is a differentiator vs flat document notebooks, enabling coverage analytics and targeted practice per syllabus bullet.[1][3]

### Question and flashcard engine

Function:
- From the normalized corpus, generate exam‑style questions and atomic flashcards with explicit provenance back to source pages.[1]

Outputs:
- MCQs in UPSC/TNPSC styles: single‑correct, assertion‑reason, match‑the‑following, true/false, with rationales and linked pages.
- Short‑answer prompts for Mains and NET, tuned by directive verbs like "discuss", "critically examine", "evaluate".
- Atomic flashcards (definitions, dates, thinkers, formulae, facts) optimized for active recall.

Design constraints:
- Every card/question stores: document ID, page range, and topic path, so a user can jump back to revision context and trust that the system is not hallucinating.
- Difficulty tagging (easy/medium/hard) based on heuristics (e.g., length, number of steps, topic rarity) plus LLM judgment.

### Spaced repetition and daily plan engine

Function:
- Treat each syllabus topic as a deck and compute a spaced‑repetition schedule backward from exam date, constrained by user availability per weekday/weekend.[1]

Daily playlist behavior:
- Determine due review cards (per SRS algorithm tuned for high‑stakes exams rather than casual language learning).
- Introduce new cards based on under‑covered high‑weight syllabus areas and user performance.
- Add a small set of PYQs or MCQs per day.

Output example:
- "60 minutes today: 25 due SRS cards, 10 new Modern History cards, 10 Polity MCQs (PYQs), 1 short Mains answer (GS II)."[3]

### PYQ ingestion and pattern analysis

Function:
- Ingest PYQ PDFs from the user plus (eventually) a curated central dataset; tag each question by year, paper, topic, difficulty, and question type.[1][3]

Outputs:
- Topic‑wise PYQ coverage percentages for the user.
- Topic frequency trends over 10–30 years: which themes are "hot" or declining.
- Pattern‑aware guidance: topics that can safely be given minimal coverage versus those that must be mastered.

Why this is a moat:
- This is exam‑specific, data‑heavy, and tied to the official syllabus structure; generic AI document tools will not invest enough to match it.

### Practice UI and dashboard

Function:
- Provide a minimal but sharp UI for:
  - Flashcards/SRS with ease ratings.
  - MCQ drills (timed/untimed, adaptive difficulty).
  - PYQ practice with filters and model answers.

Dashboard metrics:
- Syllabus coverage by topic and paper.
- Cards due today/this week.
- PYQ coverage per topic.
- Time spent vs target per week.

This module should feel more like a control panel than a coaching portal: one place where a serious aspirant can quickly see "what matters today" and execute on it.

## Feature matrix for v1

| Module | Must‑have for v1 | Can slip to v1.1 | Notes |
|--------|------------------|------------------|-------|
| PDF ingestion + OCR | Yes | Quality tuning | Without this, BYO material is impossible. |
| Exam taxonomy + syllabus mapping | Yes | Additional exams | Core moat; start with UPSC CSE GS. |
| MCQ generation with provenance | Yes | Advanced types | Single‑correct and assertion‑reason first. |
| Flashcard engine + SRS | Yes | Multi‑device sync | Essential habit‑forming loop. |
| Daily plan from exam date | Yes | Calendar integrations | MVP: simple daily playlist. |
| PYQ ingestion (user PDFs) | Yes | Central PYQ dataset | User’s own PYQs are enough for alpha. |
| PYQ trend analysis charts | No | Yes | Can be CLI/backoffice first, UI later. |
| Practice UI (web) | Yes | Native mobile apps | Target responsive web first. |
| Mains model answers | No | Yes | Defer full answer evaluation to v2. |
| Coaching/teacher dashboards | No | Yes | Separate B2B track. |

## Architecture overview (conceptual)

### High‑level components

- Ingestion service: handles PDF upload, OCR, chunking, and metadata storage.
- Taxonomy/classifier service: maps chunks to exam taxonomy and syllabus bullets.
- Question engine: LLM‑backed service generating MCQs, short‑answers, and flashcards from chunked text.
- Scheduler/SRS engine: stores user performance on cards/questions and computes due items per day.
- PYQ engine: ingests and tags PYQs, computes topic frequencies and coverage.
- API gateway: exposes secure endpoints to the front‑end for practice sessions and dashboards.
- Front‑end: minimal React/Next (or Flutter web) app for dashboard, decks, and drills.

### Data model (simplified)

Key entities:
- User, ExamProfile (exam type, attempt year, target date, daily hours).
- Document, Page, Chunk (with text, embedding vectors, topic path).
- SyllabusItem (hierarchical tree), SyllabusCoverage (per user, per item).
- Question (type, text, options, answer, explanation, difficulty, source references, topic path).
- Card (subset of Question or atomic fact), CardReview (timestamp, rating, nextDueAt).
- PYQQuestion (year, paper, marks, topic, difficulty, tags).
- DailyPlan (date, list of tasks, estimated minutes, completion status).

This architecture aligns with the user’s prior experience in building structured edtech apps (MCQs, mocks, syllabus workspaces) and LLM‑backed backends.

## Phased delivery plan and milestones

### Phase 0 – Discovery and UX definition (1–2 weeks)

Goals:
- Validate workflows with 3–5 serious aspirants (including the founder) using low‑fidelity prototypes and Notion/Sheets.
- Lock narrow v1 exam scope (e.g., UPSC CSE GS + Prelims) and confirm the daily playlist metaphor resonates.

Key tasks:
- Map the detailed UPSC GS + Prelims syllabus into a clean taxonomy with topics/sub‑topics and link to official PDFs.[2][3]
- Draft UX flows for: onboarding (exam selection, hours, date), upload, deck view, MCQ drill, PYQ practice, dashboard.
- Define success metrics for alpha: e.g., D7 retention for daily plans, number of cards reviewed per week, % syllabus covered.

Deliverables:
- UX flow diagrams and wireframes.
- Taxonomy + syllabus JSON seed.
- Product spec for v1 modules.

### Phase 1 – Backend foundations (4–6 weeks)

Goals:
- Build ingestion, taxonomy mapping, basic question generation, and a working SRS store.

Key tasks:
- Implement PDF upload, storage, basic OCR, and chunking with metadata.
- Implement exam taxonomy mapping for UPSC GS + Prelims and API for listing syllabus items.
- Implement simple LLM‑powered question generation for MCQs and flashcards with provenance.
- Implement SRS data model and a first‑cut scheduling algorithm (e.g., SM‑2 variant tuned to exam horizon).
- Implement minimal authentication and user profile (ExamProfile) storage.

Milestones:
- Given a small set of PDFs and a target exam/date, the system produces:
  - A mapped syllabus view with coverage bars.
  - A deck of initial cards/questions per topic.

### Phase 2 – PYQ engine and daily planner (3–4 weeks)

Goals:
- Integrate PYQ ingestion and topic tagging; build the daily playlist engine.

Key tasks:
- Ingest user PYQ PDFs (starting with UPSC GS + Prelims), tag questions by year/paper/topic.
- Implement topic‑wise PYQ coverage and simple frequency statistics.
- Implement daily planner that combines SRS due cards, new cards from under‑covered topics, and a small PYQ/MCQ set per day.
- Build APIs to fetch a daily playlist for the front‑end.

Milestones:
- For a dogfooding user, the system can generate a realistic daily plan each day and adjust based on what was actually completed.[3]

### Phase 3 – Practice UI and alpha launch (3–4 weeks)

Goals:
- Ship a minimal, reliable practice UI and onboard 5–20 alpha users.

Key tasks:
- Implement practice UI: flashcard/SRS view with rating, MCQ drill screens, simple PYQ practice screen.
- Build dashboard cards for syllabus coverage, due cards, PYQ coverage, and time spent.
- Add lightweight analytics (events per practice action) and error logging.
- Ship closed alpha, instrument feedback loops (NPS, qualitative interviews).

Milestones:
- At least 5 users actively using the system for 2+ weeks.
- Qualitative validation that the daily plan + practice surfaces feel like an "exam autopilot" rather than a toy quiz app.

## Risks and mitigations

### Risk 1 – Quality of generated questions

If MCQs and flashcards feel low quality or obviously hallucinated, user trust collapses quickly. Mitigations:
- Strict provenance enforcement: every question links to a specific page and passage; show these links prominently.
- Conservative prompts and templates that bias towards fact‑based recall rather than creative inference.
- Founder‑in‑the‑loop review for early decks (especially UPSC GS) to tune prompts and heuristics.

### Risk 2 – Over‑scope vs solo founder bandwidth

The full "exam autopilot" vision is large, and there is a tendency to overbuild architecture and under‑ship user value.[4] Mitigations:
- Aggressively limit v1 exams and features; focus on a single exam (UPSC CSE GS) and a small set of modules.
- Reuse existing infra patterns from prior projects (Next.js, LLM integration stacks, deployment pipelines) instead of reinventing.
- Treat everything beyond the daily playlist and practice UI as v1.1+.

### Risk 3 – Competition from incumbents

UPSC/PSC AI tools and NotebookLM‑style products can move fast and copy surface features. Mitigations:
- Double down on BYO material and exam‑specific modeling, which are harder to copy quickly.
- Focus on depth for a narrow ICP (serious self‑studying aspirants) rather than breadth.
- Collect longitudinal performance and coverage data that feeds into personalization models over time.

### Risk 4 – Engagement and habit formation

Even the best engine fails if users do not stick with it daily. Mitigations:
- Design the daily playlist to be realistic, not aspirational, based on user availability and past completion.
- Use small, visible streaks and progress markers, but avoid turning it into a gamified distraction.
- Integrate within the founder’s own daily UPSC/NET/TNPSC prep as a primary user, so product decisions are grounded in lived pain.

## Suggested Linear backlog structure (conceptual)

Epics:
- EPIC 1 – Product discovery and exam taxonomy.
- EPIC 2 – Ingestion and syllabus mapping engine.
- EPIC 3 – Question and flashcard engine.
- EPIC 4 – SRS + daily planner.
- EPIC 5 – PYQ ingestion and analytics.
- EPIC 6 – Practice UI and dashboard.
- EPIC 7 – Alpha launch, analytics, and feedback.

Within each epic, issues should be small, testable, and phrased with clear "Done when" criteria, following the user’s established Linear planning style from projects like Trainer Suite.[4] Dependencies should reflect the natural pipeline: ingestion before questions, questions before SRS, SRS before daily plans, and so on.