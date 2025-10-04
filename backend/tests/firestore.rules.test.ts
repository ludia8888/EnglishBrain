import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { readFileSync } from 'fs';

const PROJECT_ID = 'englishbrain-f43f0';
const HOST = process.env.FIRESTORE_EMULATOR_HOST;
const EMULATOR_AVAILABLE = Boolean(HOST);

if (!EMULATOR_AVAILABLE) {
  describe.skip('Firestore security rules (emulator required)', () => {
    it('skipped when FIRESTORE_EMULATOR_HOST not set', () => {
      console.warn(
        'Skipping Firestore rules tests; run via `firebase emulators:exec --only firestore "npm test -- --runTestsByPath tests/firestore.rules.test.ts"`'
      );
    });
  });
} else {
  const [host, portString] = HOST!.split(':');
  const port = Number(portString ?? 8080);

  describe('Firestore security rules', () => {
    let testEnv: Awaited<ReturnType<typeof initializeTestEnvironment>>;

    beforeAll(async () => {
      const rules = readFileSync('firestore.rules', 'utf8');
      testEnv = await initializeTestEnvironment({
        projectId: PROJECT_ID,
        firestore: { rules, host, port },
      });
    });

    afterAll(async () => {
      await testEnv.cleanup();
    });

    afterEach(async () => {
      await testEnv.clearFirestore();
    });

    it('allows a user to read their own profile', async () => {
      const authed = testEnv.authenticatedContext('user-123');
      const db = authed.firestore();
      await assertSucceeds(db.collection('users').doc('user-123').set({ displayName: 'Alice' }));
      await assertSucceeds(db.collection('users').doc('user-123').get());
    });

    it('prevents a user from reading another profile', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('user-abc').set({ displayName: 'Bob' });
      });

      const otherUserDb = testEnv.authenticatedContext('user-xyz').firestore();
      await assertFails(otherUserDb.collection('users').doc('user-abc').get());
    });

    it('allows a user to create their own profile', async () => {
      const db = testEnv.authenticatedContext('user-create').firestore();
      await assertSucceeds(db.collection('users').doc('user-create').set({ displayName: 'Creator' }));
    });

    it('denies creation when uid does not match', async () => {
      const db = testEnv.authenticatedContext('user-one').firestore();
      await assertFails(db.collection('users').doc('user-two').set({ displayName: 'Intruder' }));
    });

    it('denies unauthenticated access', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.collection('users').doc('anon').get());
      await assertFails(db.collection('users').doc('anon').set({ displayName: 'Anon' }));
    });

    it('allows authenticated reads of lessons but denies writes and unauthenticated access', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('lessons').doc('lesson-1').set({
          lessonId: 'lesson-1',
          level: 1,
          correctSequence: ['a', 'b'],
        });
      });

      const authed = testEnv.authenticatedContext('reader').firestore();
      await assertSucceeds(authed.collection('lessons').doc('lesson-1').get());
      await assertFails(authed.collection('lessons').doc('lesson-1').set({ level: 2 }));

      const unauth = testEnv.unauthenticatedContext().firestore();
      await assertFails(unauth.collection('lessons').doc('lesson-1').get());
    });

    it('enforces level test submission ownership', async () => {
      const authedDb = testEnv.authenticatedContext('user-level').firestore();
      await assertSucceeds(
        authedDb.collection('level_tests').doc('submission-1').set({
          uid: 'user-level',
          startedAt: new Date().toISOString(),
          completedAt: new Date().toISOString(),
          createdAt: new Date().toISOString(),
          result: {
            recommendedLevel: 2,
            confidence: 0.8,
            rationale: 'test',
            nextLessonId: 'lesson-1',
          },
        })
      );

      await assertSucceeds(authedDb.collection('level_tests').doc('submission-1').get());

      const otherDb = testEnv.authenticatedContext('user-other').firestore();
      await assertFails(otherDb.collection('level_tests').doc('submission-1').get());
      await assertFails(
        otherDb.collection('level_tests').doc('submission-1').set({ uid: 'user-other' }, { merge: true })
      );
    });
  });
}
