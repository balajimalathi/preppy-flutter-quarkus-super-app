ALTER TABLE users
    ADD COLUMN onboarding_completed_at TIMESTAMPTZ;

CREATE TABLE student_profiles (
    user_id UUID PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    learning_target TEXT NOT NULL CHECK (length(trim(learning_target)) BETWEEN 1 AND 200),
    study_level TEXT NOT NULL CHECK (study_level IN ('school', 'undergraduate', 'postgraduate', 'competitive_exam', 'professional')),
    goal_type TEXT NOT NULL CHECK (goal_type IN ('subject', 'course', 'competitive_exam', 'professional_cert')),
    target_date DATE NOT NULL,
    language_preference TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE learning_capability_profiles (
    user_id UUID PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    daily_minutes INT NOT NULL CHECK (daily_minutes BETWEEN 5 AND 480),
    preferred_learning_methods TEXT[] NOT NULL CHECK (array_length(preferred_learning_methods, 1) >= 1),
    baseline_confidence INT CHECK (baseline_confidence BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE notification_preferences (
    user_id UUID PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    notifications_enabled BOOLEAN NOT NULL DEFAULT false,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT quiet_hours_pair CHECK (
        (quiet_hours_start IS NULL AND quiet_hours_end IS NULL)
        OR (quiet_hours_start IS NOT NULL AND quiet_hours_end IS NOT NULL)
    ),
    CONSTRAINT quiet_hours_distinct CHECK (
        quiet_hours_start IS NULL OR quiet_hours_start <> quiet_hours_end
    )
);
