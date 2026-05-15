#!/usr/bin/env node
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { mintFirebaseIdToken } from '../../backend/scripts/lib/mint-id-token.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));

const serviceAccountPath =
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH ??
    join(__dirname, 'service-account.json');

const webApiKey = process.env.FIREBASE_WEB_API_KEY;
const uid = process.env.FIREBASE_TEST_UID ?? 'dev-swagger-test';

try {
    const { idToken, expiresIn, uid: mintedUid } = await mintFirebaseIdToken({
        serviceAccountPath: resolve(serviceAccountPath),
        webApiKey,
        uid,
    });
    console.error(`uid=${mintedUid} expiresIn=${expiresIn}s`);
    console.log(idToken);
} catch (err) {
    console.error(err.message ?? err);
    process.exit(1);
}
