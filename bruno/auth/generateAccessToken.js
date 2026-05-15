import { GoogleAuth } from 'google-auth-library';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const keyFilePath = join(__dirname, 'service-account.json');
const auth = new GoogleAuth({
    keyFile: keyFilePath,
    scopes: 'https://www.googleapis.com/auth/firebase.messaging',
});

async function getAccessToken() {
    const client = await auth.getClient();
    const accessToken = await client.getAccessToken();
    console.log('Access Token:', accessToken);
}

getAccessToken().catch(console.error);
