-- Profile fields and audit columns for users.
ALTER TABLE users
    ADD COLUMN avatar_url  TEXT,
    ADD COLUMN metadata    JSONB NOT NULL DEFAULT '{}',
    ADD COLUMN created_by  UUID REFERENCES users (id),
    ADD COLUMN updated_by  UUID REFERENCES users (id);
