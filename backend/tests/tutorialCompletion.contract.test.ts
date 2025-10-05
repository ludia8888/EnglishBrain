import request from 'supertest';
import * as admin from 'firebase-admin';

import app from '../src/http/app';
import { getFirestore } from '../src/firebaseAdmin';
import { buildDefaultUserProfile } from '../src/services/userService';

const FIRESTORE_HOST = process.env.FIRESTORE_EMULATOR_HOST;
const AUTH_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST;
const EMULATORS_AVAILABLE = Boolean(FIRESTORE_HOST && AUTH_HOST);

const TEST_PROJECT_ID = process.env.GCLOUD_PROJECT ?? 'englishbrain-contract-tests';
const TEST_USER_UID = 'tutorial-user';
const TEST_USER_EMAIL = 'tutorial@example.com';
const TEST_USER_PASSWORD = 'Tutorial#1234';

async function postJson<T>(path: string, idToken: string, body: unknown) {
  const res = await request(app)
    .post(path)
    .set('Authorization', `Bearer ${idToken}`)
    .set('Content-Type', 'application/json')
    .send(body as any);
  return { statusCode: res.status, body: res.body as T };
}

if (!EMULATORS_AVAILABLE) {
  describe.skip('Tutorial completion API (emulator)', () => {
    it('requires emulators', () => {});
  });
} else {
  describe('Tutorial completion API (emulator)', () => {
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
      await firestore.collection('users').doc(TEST_USER_UID).set(profile);

      const auth = admin.auth();
      try {
        await auth.deleteUser(TEST_USER_UID);
      } catch (_) {}
      await auth.createUser({ uid: TEST_USER_UID, email: TEST_USER_EMAIL, password: TEST_USER_PASSWORD });

      const response = await fetch(
        `http://${AUTH_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key`,
        {
          method: 'POST',
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify({ email: TEST_USER_EMAIL, password: TEST_USER_PASSWORD, returnSecureToken: true }),
        }
      );
      const payload = (await response.json()) as { idToken: string };
      idToken = payload.idToken;
    });

    afterEach(async () => {
      await getFirestore().collection('users').doc(TEST_USER_UID).delete();
      try {
        await admin.auth().deleteUser(TEST_USER_UID);
      } catch (_) {}
    });

    afterAll(async () => {
      await admin.app().delete();
    });

    it('marks tutorial complete and unlocks personalization', async () => {
      const completionAt = new Date().toISOString();
      const { statusCode, body } = await postJson<{ tutorialId: string; streakEligible: boolean; personalizationUnlocked: boolean }>(
        '/users/me/tutorial-completions',
        idToken,
        { tutorialId: 'onboarding-1', completedAt: completionAt }
      );

      expect(statusCode).toBe(202);
      expect(body.tutorialId).toBe('onboarding-1');
      expect(body.personalizationUnlocked).toBe(true);

      const doc = await admin.firestore().collection('users').doc(TEST_USER_UID).get();
      const data = doc.data() as any;
      expect(data.flags?.tutorialCompleted).toBe(true);
      expect(data.flags?.personalizationReady).toBe(true);
    });
  });
}

