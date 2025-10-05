import http from 'http';
import request from 'supertest';

import * as admin from 'firebase-admin';

import app from '../src/http/app';
import { getFirestore } from '../src/firebaseAdmin';
import { buildDefaultUserProfile } from '../src/services/userService';
import { LevelTestSubmissionPayload, LevelTestResult } from '../src/types/levelTest';

const FIRESTORE_HOST = process.env.FIRESTORE_EMULATOR_HOST;
const AUTH_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST;

const EMULATOR_REQUIRED_MESSAGE =
  'Firestore/Auth emulators not detected. Run via `firebase emulators:exec --only firestore,auth "npm run test:contract"`';

const TEST_PROJECT_ID = process.env.GCLOUD_PROJECT ?? 'englishbrain-contract-tests';
const TEST_USER_UID = 'level-test-user';
const TEST_USER_EMAIL = 'leveltest@example.com';
const TEST_USER_PASSWORD = 'LevelTest#1234';

const LESSON_IDS = Array.from({ length: 10 }, (_, index) => `lesson-${index + 1}`);

const EMULATORS_AVAILABLE = Boolean(FIRESTORE_HOST && AUTH_HOST);

async function postJson<T>(path: string, idToken: string, body: unknown) {
  const res = await request(app)
    .post(path)
    .set('Authorization', `Bearer ${idToken}`)
    .set('Content-Type', 'application/json')
    .send(body as any);
  return { statusCode: res.status, body: res.body as T };
}

if (!EMULATORS_AVAILABLE) {
  describe.skip('Level test API contract (emulator)', () => {
    it('requires Firestore/Auth emulators', () => {
      console.warn(EMULATOR_REQUIRED_MESSAGE);
    });
  });
} else {
 describe('Level test API contract (emulator)', () => {
    let idToken: string;

    beforeAll(async () => {
      process.env.GCLOUD_PROJECT = TEST_PROJECT_ID;
      if (!admin.apps.length) {
        admin.initializeApp({ projectId: TEST_PROJECT_ID });
      }
      jest.setTimeout(30000);
    });

    beforeEach(async () => {
      const firestore = getFirestore();
      const profile = buildDefaultUserProfile({
        uid: TEST_USER_UID,
        email: TEST_USER_EMAIL,
        locale: 'ko-KR',
        timezone: 'Asia/Seoul',
      });

      await firestore.collection('users').doc(TEST_USER_UID).set(profile);

      await admin.firestore().recursiveDelete(admin.firestore().collection('lessons'));
      const batch = admin.firestore().batch();
      LESSON_IDS.forEach((lessonId, index) => {
        const ref = admin.firestore().collection('lessons').doc(lessonId);
        batch.set(ref, {
          lessonId,
          level: (index % 5) + 1,
          correctSequence: ['token-a', `token-${index}`],
          tokenPool: ['token-a', `token-${index}`, 'token-x'],
          prompt: {
            ko: `문장 ${index + 1}`,
            en: `Sentence ${index + 1}`,
          },
          levelTest: true,
        });
      });
      await batch.commit();

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
      await admin.firestore().recursiveDelete(admin.firestore().collection('lessons'));
      await admin.firestore().recursiveDelete(admin.firestore().collection('level_tests'));
    });

    afterAll(async () => {
      try {
        await admin.auth().deleteUser(TEST_USER_UID);
      } catch (_) {
        // ignore
      }
      await admin.app().delete();
    });

    it(
      'accepts level test submission and stores result',
      async () => {
        const attempts = LESSON_IDS.map((lessonId, index) => ({
        itemId: lessonId,
        selectedTokenIds: ['token-a', `token-${index}`],
        timeSpentMs: 15000,
        hintsUsed: index % 4 === 0 ? 1 : 0,
      }));

      const submission: LevelTestSubmissionPayload = {
        attempts,
        startedAt: new Date(Date.now() - 120000).toISOString(),
        completedAt: new Date().toISOString(),
      };

      const { statusCode, body } = await postJson<LevelTestResult>('/level-tests', idToken, submission);

      if (statusCode !== 200) {
        console.error('Level test error response', body);
        throw new Error(`Expected HTTP 200, received ${statusCode}`);
      }

      expect(body.recommendedLevel).toBeGreaterThanOrEqual(1);
      expect(body.recommendedLevel).toBeLessThanOrEqual(5);
      expect(body.nextLessonId).toBeTruthy();
      expect(body.confidence).toBeGreaterThanOrEqual(0);
      expect(body.confidence).toBeLessThanOrEqual(1);

      const stored = await admin.firestore().collection('level_tests').where('uid', '==', TEST_USER_UID).get();
      expect(stored.empty).toBe(false);

      const userDoc = await admin.firestore().collection('users').doc(TEST_USER_UID).get();
      expect(userDoc.exists).toBe(true);
      const userData = userDoc.data();
      expect(userData?.flags?.levelTestCompleted).toBe(true);
      expect(userData?.provisionalLevel).toBe(body.recommendedLevel);
    },
      30000
    );

    it('rejects invalid level test payload', async () => {
      const submission: Partial<LevelTestSubmissionPayload> = {
        attempts: [],
        startedAt: 'not-a-date',
        completedAt: 'also-not-a-date',
      };

      const { statusCode, body } = await postJson<{ message: string }>('/level-tests', idToken, submission);

      expect(statusCode).toBe(400);
      expect(body.message).toBeDefined();
    });

    it('enforces level test rate limit', async () => {
      const makeSubmission = () => ({
        attempts: LESSON_IDS.map((lessonId, index) => ({
          itemId: lessonId,
          selectedTokenIds: ['token-a', `token-${index}`],
          timeSpentMs: 12000,
          hintsUsed: 0,
        })),
        startedAt: new Date(Date.now() - 60000).toISOString(),
        completedAt: new Date().toISOString(),
      });

      for (let i = 0; i < 2; i += 1) {
        const { statusCode } = await postJson<LevelTestResult>('/level-tests', idToken, makeSubmission());
        expect(statusCode).toBe(200);
      }

      const { statusCode, body } = await postJson<{ message: string }>('/level-tests', idToken, makeSubmission());
      expect(statusCode).toBe(429);
      expect(body.message).toContain('limit');
    });
  });
}
