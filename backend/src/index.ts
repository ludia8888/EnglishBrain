import * as functions from 'firebase-functions';

import app from './http/app';
import { handleAuthUserCreate } from './triggers/auth';

export const api = functions.https.onRequest(app);
export const authOnboardUser = functions.auth.user().onCreate(handleAuthUserCreate);
