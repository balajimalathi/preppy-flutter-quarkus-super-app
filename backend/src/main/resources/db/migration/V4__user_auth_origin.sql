-- Auth-provider agnostic user identity: origin + external_uid, FCM token for push.
ALTER TABLE users
    RENAME COLUMN firebase_uid TO external_uid;

ALTER TABLE users
    ADD COLUMN origin    TEXT NOT NULL DEFAULT 'firebase',
    ADD COLUMN fcm_token TEXT;

ALTER TABLE users
    DROP COLUMN IF EXISTS exam,
    DROP COLUMN IF EXISTS daily_minutes,
    DROP COLUMN IF EXISTS metadata;

ALTER TABLE users
    DROP CONSTRAINT IF EXISTS users_firebase_uid_key;

ALTER TABLE users
    ADD CONSTRAINT users_origin_external_uid_key UNIQUE (origin, external_uid);
