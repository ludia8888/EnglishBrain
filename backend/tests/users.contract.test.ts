import http from 'http';
import { PassThrough } from 'stream';

import * as admin from 'firebase-admin';

import app from '../src/http/app';
import { getFirestore } from '../src/firebaseAdmin';
import { buildDefaultUserProfile } from '../src/services/userService';
import { HomeSummary, UserProfileDoc, WidgetSnapshot } from '../src/types/user';

const FIRESTORE_HOST = process.env.FIRESTORE_EMULATOR_HOST;
const AUTH_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST;

const EMULATOR_REQUIRED_MESSAGE =
  'Firestore/Auth emulators not detected. Run via `firebase emulators:exec --only firestore,auth "npm run test:contract"`';

const TEST_PROJECT_ID = process.env.GCLOUD_PROJECT ?? 'englishbrain-contract-tests';
const TEST_USER_UID = 'contract-user';
const TEST_USER_EMAIL = 'contract@example.com';
const TEST_USER_PASSWORD = 'Contract#1234';

const EMULATORS_AVAILABLE = Boolean(FIRESTORE_HOST && AUTH_HOST);

type InvokeOptions = {
  method?: string;
  headers?: Record<string, string>;
  body?: unknown;
};

async function invokeJson<T>(path: string, options: InvokeOptions = {}) {
  const method = options.method ?? 'GET';
  const headers: Record<string, string> = {
    host: 'localhost',
    'content-type': 'application/json',
    ...(options.headers ?? {}),
  };

  const socket = new PassThrough();
  const req = new http.IncomingMessage(socket as unknown as any);
  req.method = method;
  req.url = path;
  req.headers = Object.keys(headers).reduce<Record<string, string>>((acc, key) => {
    acc[key.toLowerCase()] = headers[key];
    return acc;
  }, {});

  if (options.body !== undefined) {
    const payload = typeof options.body === 'string' ? options.body : JSON.stringify(options.body);
    socket.end(payload);
  } else {
    socket.end();
  }

  const res = new http.ServerResponse(req);
  const resSocket = new PassThrough();
  res.assignSocket(resSocket as unknown as any);
  const chunks: Buffer[] = [];

  res.write = ((chunk: any) => {
    if (chunk) {
      chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
    }
    return true;
  }) as typeof res.write;

  const originalEnd = res.end.bind(res);
  res.end = ((chunk?: any, encoding?: any, callback?: any) => {
    if (chunk && typeof chunk !== 'function') {
      chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
    }
    return originalEnd(chunk, encoding, callback);
  }) as typeof res.end;

  return new Promise<{ statusCode: number; headers: http.OutgoingHttpHeaders; body: string }>((resolve, reject) => {
    res.on('finish', () => {
      const body = Buffer.concat(chunks).toString();
      resolve({
        statusCode: res.statusCode ?? 200,
        headers: res.getHeaders(),
        body,
      });
    });

    res.on('error', reject);

    try {
      app(req as any, res as any);
    } catch (error) {
      reject(error);
    }
  }).then(({ statusCode, headers: responseHeaders, body }) => ({
    statusCode,
    headers: responseHeaders,
    body: body ? (JSON.parse(body) as T) : ({} as T),
  }));
}

if (!EMULATORS_AVAILABLE) {
  describe.skip('Users API contract (emulator)', () => {
    it('requires Firestore/Auth emulators', () => {
      console.warn(EMULATOR_REQUIRED_MESSAGE);
    });
  });
} else {
  describe('Users API contract (emulator)', () => {
    let idToken: string;

    beforeAll(async () => {
      process.env.GCLOUD_PROJECT = TEST_PROJECT_ID;
      if (!admin.apps.length) {
        admin.initializeApp({ projectId: TEST_PROJECT_ID });
      }
      jest.setTimeout(20000);
    });

    beforeEach(async () => {
      const firestore = getFirestore();
      const profile = buildDefaultUserProfile({
        uid: TEST_USER_UID,
        email: TEST_USER_EMAIL,
        locale: 'ko-KR',
        timezone: 'Asia/Seoul',
      });

      profile.stats = {
        ...profile.stats,
        currentStreak: 4,
        longestStreak: 7,
        sessionsCompletedThisWeek: 3,
        brainTokens: 5,
        lastSessionAt: '2024-01-05T21:00:00.000Z',
      };

      await firestore.collection('users').doc(TEST_USER_UID).set(profile);

      const auth = admin.auth();
      try {
        await auth.deleteUser(TEST_USER_UID);
      } catch (error) {
        if ((error as { code?: string }).code !== 'auth/user-not-found') {
          throw error;
        }
      }

      await auth.createUser({
        uid: TEST_USER_UID,
        email: TEST_USER_EMAIL,
        password: TEST_USER_PASSWORD,
      });

      const response = await fetch(
        `http://${AUTH_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key`,
        {
          method: 'POST',
          headers: {
            'content-type': 'application/json',
          },
          body: JSON.stringify({
            email: TEST_USER_EMAIL,
            password: TEST_USER_PASSWORD,
            returnSecureToken: true,
          }),
        }
      );

      if (!response.ok) {
        throw new Error(`Failed to sign in test user: ${response.status} ${await response.text()}`);
      }
      const payload = (await response.json()) as { idToken: string };
      idToken = payload.idToken;
    });

    afterEach(async () => {
      await getFirestore().collection('users').doc(TEST_USER_UID).delete();
    });

    afterAll(async () => {
      try {
        await admin.auth().deleteUser(TEST_USER_UID);
      } catch (_) {
        // ignore
      }
      await admin.app().delete();
    });

    it('returns the user profile for /users/me', async () => {
      const { statusCode, body } = await invokeJson<UserProfileDoc>('/users/me', {
        headers: {
          authorization: `Bearer ${idToken}`,
        },
      });

      expect(statusCode).toBe(200);
      expect(body.userId).toBe(TEST_USER_UID);
      expect(body.displayName).toBeTruthy();
      expect(body.preferences.dailyGoalMinutes).toBeGreaterThan(0);
    });

    it('returns home summary derived from profile data', async () => {
      const { statusCode, body } = await invokeJson<HomeSummary>('/users/me/home', {
        headers: {
          authorization: `Bearer ${idToken}`,
        },
      });

      expect(statusCode).toBe(200);
      expect(body.dailyGoal.sentences).toBeGreaterThan(0);
      expect(body.progress.sentencesCompleted).toBeGreaterThan(0);
      expect(body.streak.current).toBe(4);
      expect(body.brainTokens.available).toBe(5);
      expect(body.recommendedActions[0].type).toBe('daily-session');
    });

    it('returns widget snapshot for the user', async () => {
      const { statusCode, body } = await invokeJson<WidgetSnapshot>('/users/me/widget-snapshot', {
        headers: {
          authorization: `Bearer ${idToken}`,
        },
      });

      expect(statusCode).toBe(200);
      expect(body.currentStreak).toBe(4);
      expect(body.sentencesRemaining).toBeGreaterThanOrEqual(0);
      expect(body.deeplink).toContain('englishbrain://');
    });
  });
}
