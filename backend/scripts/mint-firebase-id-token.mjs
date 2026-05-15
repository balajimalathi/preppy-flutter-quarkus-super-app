#!/usr/bin/env node
import { resolve } from 'node:path';
import {
    defaultServiceAccountPath,
    mintFirebaseIdToken,
    scriptsDir,
} from './lib/mint-id-token.mjs';

const serviceAccountPath =
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH ??
    defaultServiceAccountPath(scriptsDir());

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
