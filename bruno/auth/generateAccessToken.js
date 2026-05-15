const { GoogleAuth } = require('google-auth-library');
const path = require('path');
const keyFilePath = path.join(__dirname, 'service-account.json');
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