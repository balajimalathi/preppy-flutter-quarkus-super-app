#!/usr/bin/env node
import { resolve } from 'node:path';
import {
    defaultServiceAccountPath,
    mintFirebaseIdToken,
    scriptsDir,
} from './lib/mint-id-token.mjs';

/** hlp-chat dev Android key — apps/preppy_app/lib/firebase/dev/firebase_options.dart */
const DEFAULT_WEB_API_KEY = 'AIzaSyDa5XppPIzbYztTjU7IYFGQcoSnUzo-Ut0';

const serviceAccountPath =
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH ??
    defaultServiceAccountPath(scriptsDir());

const webApiKey = process.env.FIREBASE_WEB_API_KEY ?? DEFAULT_WEB_API_KEY;
const uid = process.env.FIREBASE_TEST_UID ?? 'dev-swagger-test';
const email = process.env.FIREBASE_TEST_EMAIL;

try {
    const { idToken, expiresIn, uid: mintedUid } = await mintFirebaseIdToken({
        serviceAccountPath: resolve(serviceAccountPath),
        webApiKey,
        uid,
        email,
    });
    console.error(`uid=${mintedUid} expiresIn=${expiresIn}s`);
    if (!email?.trim()) {
        console.error(
            'tip: set FIREBASE_TEST_EMAIL or FIREBASE_TEST_UID to a Firebase user with email for /users/me',
        );
    }
    console.log(idToken);
} catch (err) {
    console.error(err.message ?? err);
    process.exit(1);
}
