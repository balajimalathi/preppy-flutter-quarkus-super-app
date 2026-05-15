/**
 * @deprecated Use `npm run mint-id-token` — mints a Firebase ID token for API Bearer auth.
 * This file remains as a thin wrapper for older Bruno/docs references.
 */
import { spawnSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const mintScript = join(scriptDir, 'mint-firebase-id-token.mjs');

const result = spawnSync(process.execPath, [mintScript], {
    stdio: 'inherit',
    env: process.env,
});

process.exit(result.status ?? 1);
