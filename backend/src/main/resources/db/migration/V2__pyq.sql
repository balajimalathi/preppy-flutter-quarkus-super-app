-- Previous-year question (PYQ) ingestion + analytics.

-- =========================================================================
-- PYQ papers (one paper = one exam sitting)
-- =========================================================================
CREATE TABLE pyq_papers (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    exam            TEXT        NOT NULL,
    year            INT         NOT NULL,
    paper_code      TEXT        NOT NULL,  -- e.g. "GS-I", "Paper-2"
    source_url      TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (exam, year, paper_code)
);

-- =========================================================================
-- PYQ questions
-- =========================================================================
CREATE TABLE pyq_questions (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    paper_id        UUID        NOT NULL REFERENCES pyq_papers (id) ON DELETE CASCADE,
    syllabus_id     UUID        REFERENCES syllabus_items (id) ON DELETE SET NULL,
    qno             INT         NOT NULL,
    stem            TEXT        NOT NULL,
    options         JSONB,
    correct_key     TEXT,
    explanation     TEXT,
    difficulty      INT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (paper_id, qno)
);

CREATE INDEX idx_pyq_questions_syllabus ON pyq_questions (syllabus_id);

-- =========================================================================
-- Topic frequency (materialised view-like aggregate, refreshed nightly)
-- =========================================================================
CREATE TABLE pyq_topic_freq (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    exam            TEXT        NOT NULL,
    syllabus_id     UUID        NOT NULL REFERENCES syllabus_items (id) ON DELETE CASCADE,
    window_years    INT         NOT NULL,    -- 1, 3, 5, 10
    appearances     INT         NOT NULL DEFAULT 0,
    trend_score     DOUBLE PRECISION NOT NULL DEFAULT 0,
    computed_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (exam, syllabus_id, window_years)
);

CREATE INDEX idx_pyq_topic_freq_exam ON pyq_topic_freq (exam, trend_score DESC);
