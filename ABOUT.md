# Preppy Product Plan and PM Review

## Executive Summary

Preppy is a self-preparation system for school, university, and competitive-exam students. It starts from the learner's own material: syllabi, textbooks, handwritten notes, PDFs, videos, images, PPTs, docs, spreadsheets, and previous-year questions. Preppy turns that material into structured notebooks, topic workspaces, source-grounded explanations, MCQs, flashcards, mock exams, and a daily study plan that adapts to the learner's deadline and capability.

The product should not feel like a generic "chat with documents" tool. NotebookLM-style products are useful for summaries and Q&A, but Preppy should behave more like a curriculum engine: map the syllabus to source material, validate what the learner already knows, create a realistic plan, and keep the student moving through spaced repetition instead of last-minute cramming.

## Market And Competitive Reality

Generic AI study tools already accept documents and produce summaries, quizzes, notes, and flashcards. Their weakness is structure: they usually do not understand completion dates, syllabus coverage, source-to-topic mapping, revision cadence, or what a particular student can realistically finish.

Exam-prep products often provide strong centralized content, PYQ banks, analytics, and practice modules. Their weakness is personal context: a student's actual textbook, class notes, teacher slides, handwritten material, and local syllabus are usually second-class data.

Preppy fills the gap between those categories. It treats the student's own material as the source of truth, uses the syllabus as the curriculum spine, and builds a plan that adapts to the learner rather than presenting an endless pile of generated content.

## Product Thesis And Positioning

Core thesis: "Bring your syllabus and study material. Preppy maps it into topic workspaces, checks what you already know, builds a plan around your deadline, and nudges you through daily practice and spaced repetition."

Positioning relative to existing categories:

- Versus NotebookLM: Preppy is structured around syllabus coverage, topic workspaces, study plans, active recall, and revision schedules rather than open-ended document chat.
- Versus generic flashcard tools: Preppy generates recall tasks from mapped source material and uses the student's goal, deadline, baseline ability, and progress to decide what comes next.
- Versus exam-prep platforms: Preppy can support UPSC, NET, TNPSC, and similar competitive exams, but its broader model works for school subjects, university courses, semester exams, and professional self-study.

The strategic moat is the combination of user-owned study material, syllabus-to-source provenance, longitudinal learning data, and adaptive planning. Over time, Preppy becomes a private learning operating system for the student.

## Target Users And Initial Scope

Primary users:

- School students preparing for term exams, board exams, or specific subjects from textbooks, teacher notes, and syllabi.
- University students preparing for semester exams from course outlines, lecture slides, reference books, lab sheets, and previous papers.
- Competitive-exam aspirants preparing from a defined syllabus, PYQs, books, coaching notes, and their own revision material.

Early adopters are likely to be students who already collect material in folders, Notion, Obsidian, Anki, or Google Drive but struggle to convert that material into a day-by-day plan.

Initial scope should stay narrow enough to ship: onboarding, one notebook per subject or exam, PDF/image ingestion first, syllabus and bibliography mapping, topic workspaces, MCQs, flashcards, daily plans, spaced repetition nudges, and PYQ mapping. Rich video understanding, spreadsheets, PPT extraction, and advanced exam-specific formats can expand after the core loop works.

## Core Product Workflow

### 1. Student Onboarding

Onboarding should build a useful learner profile before the first notebook is created. It should ask what the student is learning, who they are, age or study level, goal type, target date, available time, current confidence, preferred learning methods, and notification preferences.

This profile should influence the study plan. A younger school student, a university student with one week left, and a UPSC aspirant with a one-year horizon should not receive the same plan or the same style of practice.

### 2. Notebook Creation

A notebook is the main workspace for a subject, course, or exam. The student creates a notebook with a name, learning goal, target completion date or exam date, and optional context such as class, semester, exam board, university, or competitive-exam track.

The notebook should hold all material related to that subject: syllabus, bibliography/textbooks, notes, handwritten images, PDFs, videos, PPTs, docs, spreadsheets, links, and PYQs. In v1, ingestion can begin with PDFs and images while the product language keeps the broader multimodal direction clear.

### 3. Syllabus And Source Mapping

After upload, Preppy extracts, chunks, and indexes the material. The syllabus becomes the topic tree. Textbooks, notes, slides, and other material are mapped to the relevant topics with page, chunk, or timestamp references.

Each syllabus topic gets its own workspace. The workspace should show where the topic appears in source material, what has already been covered, what is weak, and what practice is due. This is the key difference from a flat notebook: the syllabus drives the learning journey.

### 4. Baseline Validation

Once the notebook has enough mapped material, Preppy should ask random diagnostic questions to estimate the student's current knowledge. These can be lightweight MCQs, flashcards, short answers, or confidence checks.

The baseline should not become a high-stakes test. Its purpose is to help the planner decide whether the student needs first-pass learning, revision, practice, or mock-exam work for each topic.

### 5. Adaptive Study Plan

The study plan should be generated from syllabus coverage, material volume, baseline results, target date, available time, learning capability, and topic priority. The student must be able to edit the plan, because real students have holidays, classes, tests, family commitments, and uneven energy.

Once accepted, the plan becomes the daily operating system: what to learn today, what to revise, what to practice, and what can wait. The plan should favor steady progress over cramming and should rebalance when the student falls behind or completes work early.

### 6. Topic Workspaces And Practice

Every topic workspace should support multiple modes of clarity and memorization:

- Source-grounded Q&A over mapped material.
- MCQs and flashcards generated from the topic's source chunks.
- Short explanations, summaries, and examples.
- Video or media references where available.
- Review history, confidence, and next due tasks.

The experience should answer "what do I need to understand about this topic, where is it in my material, and how do I know I remember it?"

### 7. Spaced Repetition And Mobile Nudges

The mobile app should keep the learner on track through spaced repetition reminders, daily plan nudges, and lightweight review sessions. Notifications should respect study windows, quiet hours, and the student's plan rather than spamming generic reminders.

Time blocking and focus support can become part of this layer: planned study sessions, notification silencing, reminders to start, and recovery plans when a session is missed.

### 8. PYQ Mapping And Mock Exams

When a student uploads previous-year questions, Preppy should map each question to syllabus topics and source references. For competitive exams, that means paper, year, topic, difficulty, and book/page linkage. For school and university students, it can mean past semester questions or model papers linked to textbook chapters and syllabus bullets.

PYQs should support two modes: analysis and practice. Analysis shows topic frequency, coverage, and weak areas. Practice lets the student attend PYQs as a mock exam or filtered drill, then routes mistakes back into topic workspaces and spaced repetition.

## Feature Matrix For v1

| Module | Must-have for v1 | Can slip to v1.1 | Notes |
| --- | --- | --- | --- |
| Student onboarding | Yes | Rich psychometric profiling | Capture goal, level, time, deadline, preferences, and baseline context. |
| Notebook creation | Yes | Collaboration and sharing | Notebook is the core subject/exam workspace. |
| PDF/image ingestion | Yes | Video, PPT, docs, spreadsheets | Start narrow but design metadata for multimodal material. |
| Syllabus and bibliography mapping | Yes | Advanced confidence scoring | Core differentiator: topics link to textbooks/pages/chunks. |
| Baseline validation | Yes | Long adaptive diagnostics | Use lightweight random questions before plan generation. |
| Editable study plan | Yes | Calendar integrations | Plan should adapt to timeframe, ability, progress, and student edits. |
| MCQs and flashcards | Yes | Advanced exam-specific formats | Every item must retain source provenance. |
| Spaced repetition nudges | Yes | Deep focus/time-blocking automation | Mobile reminders should support the accepted plan. |
| PYQ mapping and practice | Yes | Rich trend analytics | PYQs map to syllabus and sources; mock exam mode can start simple. |

## Architecture Overview (Conceptual)

High-level components:

- Onboarding/profile service: stores learner identity, study level, goals, learning preferences, deadlines, and notification settings.
- Notebook service: owns subject or exam workspaces, notebook materials, completion dates, and workspace state.
- Ingestion service: handles file upload, extraction, OCR, chunking, metadata, and future multimodal processing.
- Mapping/classifier service: links syllabus topics to textbook pages, notes, chunks, videos, PYQs, and generated artifacts.
- Question and flashcard engine: generates source-grounded MCQs, flashcards, short prompts, explanations, and diagnostics.
- Planner/SRS engine: creates editable study plans, schedules reviews, adapts to performance, and powers mobile nudges.
- PYQ engine: ingests and maps previous-year questions, computes topic coverage, and creates mock exams.
- Dashboard and topic workspace APIs: expose today's plan, topic status, weak areas, due reviews, and source references.

Key entities:

- User, StudentProfile, LearningCapabilityProfile.
- Notebook, NotebookMaterial, SyllabusItem, TopicWorkspace.
- Document, Page, Chunk, EmbeddingRecord.
- BaselineAssessment, Question, Flashcard, CardReview.
- StudyPlan, PlanTask, NotificationPreference.
- PYQQuestion, PYQMapping, PYQMockExam.

## Phased Delivery Plan

### Phase 0: Product Definition And UX

Goals:

- Validate the notebook and topic-workspace model with school, university, and competitive-exam students.
- Define onboarding questions that are useful without feeling like a long survey.
- Draft UX flows for onboarding, notebook creation, upload, syllabus mapping, baseline validation, plan editing, topic practice, and PYQ mock exams.

### Phase 1: Notebook And Ingestion Foundations

Goals:

- Implement authenticated onboarding and profile persistence.
- Create notebooks with target dates and basic study settings.
- Upload syllabus and source material, starting with PDFs and images.
- Extract text, chunk content, preserve page references, and create topic mapping v0.

### Phase 2: Practice And Planning Core

Goals:

- Ask baseline questions after enough material has been mapped.
- Generate source-grounded MCQs and flashcards per topic.
- Build an editable daily study plan constrained by target date, available time, baseline knowledge, and material volume.
- Implement SRS review state and mobile-ready due items.

### Phase 3: PYQ And Alpha Launch

Goals:

- Ingest PYQs or past papers and map questions to syllabus topics and source references.
- Support filtered PYQ practice and simple mock exams.
- Show notebook dashboard metrics: coverage, today's plan, due reviews, weak topics, PYQ exposure, and readiness.
- Run a closed alpha with real student notebooks and measure whether students follow the plan.

## Risks And Mitigations

### Risk 1: Overbroad Input Types

Students will want to upload everything. Supporting every file type at production quality from day one would slow the product down. Mitigation: start with PDFs and images, design the material model for future formats, and expand into video, PPT, docs, and spreadsheets in priority order.

### Risk 2: Poor Mapping Quality

If syllabus-to-source mapping is wrong, the plan and practice loop lose trust. Mitigation: preserve confidence scores, expose source references, let students correct mappings, and use corrections to improve future classification.

### Risk 3: Generated Content Without Trust

Low-quality or hallucinated MCQs and flashcards will feel worse than no generation. Mitigation: require provenance for every generated artifact, validate outputs before persistence, and show the source context in the UI.

### Risk 4: Unrealistic Plans

Students ignore plans that overload them. Mitigation: constrain the planner by available minutes, deadline, backlog, baseline knowledge, and completion behavior; let students edit plans and recover from missed days.

### Risk 5: Engagement Fatigue

Notifications can become noise. Mitigation: tie nudges to due reviews and accepted plan tasks, respect quiet hours, support time blocking, and avoid generic streak pressure that distracts from learning.

## Suggested Backlog Structure

Epics:

- EPIC 1: Onboarding and student profile.
- EPIC 2: Notebook creation and material library.
- EPIC 3: Syllabus, bibliography, and topic mapping.
- EPIC 4: Baseline validation and adaptive study planning.
- EPIC 5: Topic workspaces, MCQs, flashcards, and SRS.
- EPIC 6: Mobile nudges, time blocking, and focus support.
- EPIC 7: PYQ mapping, analytics, and mock exams.
- EPIC 8: Alpha launch, analytics, privacy, and feedback.

Dependencies should follow the learning pipeline: profile before plan, notebook before upload, upload before mapping, mapping before generation, generation before SRS, SRS before daily nudges, and PYQ mapping before mock exams.