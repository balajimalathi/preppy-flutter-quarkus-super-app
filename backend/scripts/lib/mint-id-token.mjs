import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import admin from 'firebase-admin';

const IDENTITY_TOOLKIT_URL =
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken';

/**
 * Mint a Firebase ID token for local API testing (Swagger UI, curl, Bruno).
 *
 * @param {object} options
 * @param {string} options.serviceAccountPath - Path to Firebase service account JSON
 * @param {string} options.webApiKey - Firebase Web API key (from client config)
 * @param {string} [options.uid] - Firebase Auth UID for the test user
 * @param {string} [options.email] - Resolve or create user by email (sets email claim on ID token)
 * @returns {Promise<{ idToken: string, expiresIn: string, uid: string }>}
 */
export async function mintFirebaseIdToken({
    serviceAccountPath,
    webApiKey,
    uid = 'dev-swagger-test',
    email,
}) {
    if (!webApiKey?.trim()) {
        throw new Error(
            'FIREBASE_WEB_API_KEY is required. Copy it from apps/preppy_app/lib/firebase/dev/firebase_options.dart',
        );
    }

    const resolvedPath = resolve(serviceAccountPath);
    let serviceAccount;
    try {
        serviceAccount = JSON.parse(readFileSync(resolvedPath, 'utf8'));
    } catch (err) {
        throw new Error(
            `Could not read service account at ${resolvedPath}: ${err.message}`,
        );
    }

    const appName = `mint-id-token-${Date.now()}`;
    const app = admin.initializeApp(
        {
            credential: admin.credential.cert(serviceAccount),
            projectId: serviceAccount.project_id,
        },
        appName,
    );

    try {
        const auth = admin.auth(app);
        let resolvedUid = uid;
        if (email?.trim()) {
            const normalizedEmail = email.trim();
            try {
                const existing = await auth.getUserByEmail(normalizedEmail);
                resolvedUid = existing.uid;
            } catch (err) {
                if (err.code !== 'auth/user-not-found') {
                    throw err;
                }
                const created = await auth.createUser({
                    uid: uid === 'dev-swagger-test' ? undefined : uid,
                    email: normalizedEmail,
                    emailVerified: true,
                });
                resolvedUid = created.uid;
            }
        }

        const customToken = await auth.createCustomToken(resolvedUid);
        const response = await fetch(
            `${IDENTITY_TOOLKIT_URL}?key=${encodeURIComponent(webApiKey.trim())}`,
            {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    token: customToken,
                    returnSecureToken: true,
                }),
            },
        );

        const body = await response.json();
        if (!response.ok) {
            const message =
                body?.error?.message ?? JSON.stringify(body);
            throw new Error(
                `Identity Toolkit signInWithCustomToken failed (${response.status}): ${message}`,
            );
        }

        if (!body.idToken) {
            throw new Error(
                `Identity Toolkit response missing idToken: ${JSON.stringify(body)}`,
            );
        }

        return {
            idToken: body.idToken,
            expiresIn: body.expiresIn ?? '3600',
            uid: resolvedUid,
        };
    } finally {
        await app.delete().catch(() => { });
    }
}

export function defaultServiceAccountPath(fromDir) {
    return resolve(
        fromDir,
        '../src/main/resources/firebase/service-account.json',
    );
}

export function scriptsDir() {
    return fileURLToPath(new URL('..', import.meta.url));
}
