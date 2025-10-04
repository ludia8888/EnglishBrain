import * as functions from 'firebase-functions';

export const healthcheck = functions.https.onRequest((req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
