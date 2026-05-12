-- Preppy initial schema.
-- Conventions:
--   * pk = UUID v4, generated client-side or via gen_random_uuid()
--   * timestamps are stored as timestamptz, default now()
--   * every user-owned row carries user_id with FK to users(id) ON DELETE CASCADE.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =========================================================================
-- Users (mirror of Firebase users)
-- =========================================================================
CREATE TABLE users (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    firebase_uid    TEXT        NOT NULL UNIQUE,
    email           TEXT        NOT NULL,
    display_name    TEXT,
    exam            TEXT,
    daily_minutes   INT         NOT NULL DEFAULT 30,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_email ON users (email);

-- =========================================================================
-- Ingested documents (PDF / image uploads)
-- =========================================================================
CREATE TABLE ingested_docs (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    filename        TEXT        NOT NULL,
    mime_type       TEXT        NOT NULL,
    bytes           BIGINT      NOT NULL,
    status          TEXT        NOT NULL DEFAULT 'pending',  -- pending | processing | ready | failed
    error           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_docs_user ON ingested_docs (user_id, created_at DESC);

-- =========================================================================
-- Text chunks (output of OCR + chunker, indexed in Qdrant by chunk id)
-- =========================================================================
CREATE TABLE chunks (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    doc_id          UUID        NOT NULL REFERENCES ingested_docs (id) ON DELETE CASCADE,
    seq             INT         NOT NULL,
    text            TEXT        NOT NULL,
    token_count     INT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (doc_id, seq)
);

-- =========================================================================
-- Syllabus tree (taxonomy)
-- =========================================================================
CREATE TABLE syllabus_items (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    exam            TEXT        NOT NULL,
    parent_id       UUID        REFERENCES syllabus_items (id) ON DELETE CASCADE,
    code            TEXT        NOT NULL,
    title           TEXT        NOT NULL,
    depth           INT         NOT NULL DEFAULT 0,
    sort_order      INT         NOT NULL DEFAULT 0,
    UNIQUE (exam, code)
);

CREATE INDEX idx_syllabus_parent ON syllabus_items (parent_id);

-- =========================================================================
-- Questions (MCQs) generated from chunks
-- =========================================================================
CREATE TABLE questions (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    chunk_id        UUID        REFERENCES chunks (id) ON DELETE SET NULL,
    syllabus_id     UUID        REFERENCES syllabus_items (id) ON DELETE SET NULL,
    stem            TEXT        NOT NULL,
    options         JSONB       NOT NULL,   -- [{ "key": "A", "text": "..." }, ...]
    correct_key     TEXT        NOT NULL,
    explanation     TEXT,
    difficulty      INT         NOT NULL DEFAULT 3,  -- 1..5
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_questions_user ON questions (user_id, created_at DESC);
CREATE INDEX idx_questions_syllabus ON questions (syllabus_id);

-- =========================================================================
-- Flashcards (cloze / Q&A)
-- =========================================================================
CREATE TABLE flashcards (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    chunk_id        UUID        REFERENCES chunks (id) ON DELETE SET NULL,
    syllabus_id     UUID        REFERENCES syllabus_items (id) ON DELETE SET NULL,
    front           TEXT        NOT NULL,
    back            TEXT        NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_flashcards_user ON flashcards (user_id);

-- =========================================================================
-- SRS state (one row per (user, card) — covers questions & flashcards via kind)
-- =========================================================================
CREATE TABLE srs_state (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    card_id         UUID        NOT NULL,
    card_kind       TEXT        NOT NULL,  -- 'question' | 'flashcard'
    ease_factor     DOUBLE PRECISION NOT NULL DEFAULT 2.5,
    interval_days   INT         NOT NULL DEFAULT 0,
    repetitions     INT         NOT NULL DEFAULT 0,
    due_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_reviewed   TIMESTAMPTZ,
    UNIQUE (user_id, card_id, card_kind)
);

CREATE INDEX idx_srs_due ON srs_state (user_id, due_at);

-- =========================================================================
-- Daily plan (materialised per user per day)
-- =========================================================================
CREATE TABLE daily_plans (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    plan_date       DATE        NOT NULL,
    items           JSONB       NOT NULL,
    minutes_budget  INT         NOT NULL,
    completed       BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, plan_date)
);
