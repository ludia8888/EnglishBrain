import { getFirestore } from '../firebaseAdmin';
import {
  AttemptSubmissionPayload,
  BrainBurstState,
  CheckpointSubmissionPayload,
  SessionCreatePayload,
  SessionDoc,
  SessionUpdatePayload,
} from '../types/session';
import { generateId } from '../utils/id';

import { calculateSessionSummary, scoreAttempt } from './scoringService';
import { applySessionCompletion } from './userService';

const SESSIONS_COLLECTION = 'sessions';
const ATTEMPTS_COLLECTION = 'attempts';
const CHECKPOINTS_COLLECTION = 'session_checkpoints';

export async function createSession(uid: string, payload: SessionCreatePayload): Promise<SessionDoc> {
  const now = new Date();
  const sessionDoc: SessionDoc = {
    sessionId: generateId('sess'),
    uid,
    mode: payload.mode,
    status: 'pending',
    startedAt: now.toISOString(),
    expiresAt: new Date(now.getTime() + 60 * 60 * 1000).toISOString(),
    source: 'online',
    phases: buildDefaultPhases(),
    items: buildDefaultItems(payload.patternFocus),
    brainBurst: buildBrainBurstState(),
    createdAt: now.toISOString(),
    updatedAt: now.toISOString(),
  };

  await getFirestore().collection(SESSIONS_COLLECTION).doc(sessionDoc.sessionId).set(sessionDoc);
  return sessionDoc;
}

export async function getSession(uid: string, sessionId: string): Promise<SessionDoc | null> {
  const snapshot = await getFirestore().collection(SESSIONS_COLLECTION).doc(sessionId).get();
  if (!snapshot.exists) {
    return null;
  }
  const data = snapshot.data() as SessionDoc;
  return data.uid === uid ? data : null;
}

export async function listSessions(uid: string, limit = 20): Promise<SessionDoc[]> {
  const ref = getFirestore()
    .collection(SESSIONS_COLLECTION)
    .where('uid', '==', uid)
    .orderBy('createdAt', 'desc')
    .limit(limit);
  const snapshot = await ref.get();
  return snapshot.docs.map((doc) => doc.data() as SessionDoc);
}

export async function logCheckpoint(uid: string, sessionId: string, payload: CheckpointSubmissionPayload) {
  const session = await getSession(uid, sessionId);
  if (!session) {
    throw new Error('Session not found');
  }

  const data = {
    ...payload,
    sessionId,
    uid,
    createdAt: new Date().toISOString(),
  };

  await getFirestore().collection(CHECKPOINTS_COLLECTION).doc(payload.checkpointId).set(data, { merge: true });
  await touchSession(sessionId);
  return data;
}

export async function logAttempt(uid: string, sessionId: string, payload: AttemptSubmissionPayload) {
  const session = await getSession(uid, sessionId);
  if (!session) {
    throw new Error('Session not found');
  }

  const scoring = scoreAttempt(payload);

  const data = {
    ...payload,
    sessionId,
    uid,
    createdAt: new Date().toISOString(),
    score: scoring.score,
    accuracy: scoring.accuracy,
  };

  await getFirestore().collection(ATTEMPTS_COLLECTION).doc(payload.attemptId).set(data, { merge: true });
  await touchSession(sessionId);
  return data;
}

export async function listAttempts(uid: string, sessionId: string, verdict?: string) {
  const session = await getSession(uid, sessionId);
  if (!session) {
    throw new Error('Session not found');
  }
  let query = getFirestore().collection(ATTEMPTS_COLLECTION).where('sessionId', '==', sessionId);
  if (verdict) {
    query = query.where('verdict', '==', verdict);
  }
  const snapshot = await query.get();
  return snapshot.docs.map((doc) => doc.data());
}

export async function updateSession(uid: string, sessionId: string, payload: SessionUpdatePayload) {
  const session = await getSession(uid, sessionId);
  if (!session) {
    throw new Error('Session not found');
  }
  const attemptsSnapshot = await getFirestore()
    .collection(ATTEMPTS_COLLECTION)
    .where('sessionId', '==', sessionId)
    .get();
  const attempts = attemptsSnapshot.docs.map((doc) => doc.data() as AttemptSubmissionPayload);
  const summary = calculateSessionSummary(session, attempts);

  const update = {
    status: payload.status,
    summary,
    updatedAt: new Date().toISOString(),
  };
  await getFirestore().collection(SESSIONS_COLLECTION).doc(sessionId).set(update, { merge: true });
  if (payload.status === 'completed') {
    await applySessionCompletion(uid, summary);
  }
  return { ...session, ...update } as SessionDoc;
}

function buildBrainBurstState(): BrainBurstState {
  return {
    active: false,
    multiplier: 2,
    eligibleAt: null,
    sessionsUntilActivation: 5,
  };
}

function buildDefaultPhases() {
  return [
    {
      phaseId: 'phase_warmup',
      label: 'Warm-up',
      phaseType: 'warm-up' as const,
      order: 1,
      targetSentences: 3,
      targetDurationSeconds: 180,
      itemIds: ['item_1', 'item_2', 'item_3'],
      comboRules: {
        base: 10,
        bonusPerStreak: 5,
      },
      checkpointStatus: {
        reached: false,
      },
    },
    {
      phaseId: 'phase_focus',
      label: 'Focus Zone',
      phaseType: 'focus' as const,
      order: 2,
      targetSentences: 6,
      targetDurationSeconds: 480,
      itemIds: ['item_4', 'item_5', 'item_6', 'item_7', 'item_8', 'item_9'],
      comboRules: {
        base: 15,
        bonusPerStreak: 8,
      },
      checkpointStatus: {
        reached: false,
      },
    },
    {
      phaseId: 'phase_cooldown',
      label: 'Cool-down',
      phaseType: 'cool-down' as const,
      order: 3,
      targetSentences: 3,
      targetDurationSeconds: 180,
      itemIds: ['item_10', 'item_11', 'item_12'],
      comboRules: {
        base: 10,
        bonusPerStreak: 5,
      },
      checkpointStatus: {
        reached: false,
      },
    },
  ];
}

function buildDefaultItems(patternFocus?: string[]) {
  const tags = patternFocus && patternFocus.length ? patternFocus : ['time-adverb'];
  return tags.map((tag, index) => ({
    itemId: `item_${index + 1}`,
    prompt: {
      ko: '나는 어제 친구를 만났다',
      enReference: 'I met a friend yesterday',
    },
    frame: {
      slots: [
        { role: 'S' as const, label: '주어', optional: false },
        { role: 'V' as const, label: '동사', optional: false },
        { role: 'O' as const, label: '목적어', optional: false },
        { role: 'M' as const, label: '수식어', optional: true },
      ],
    },
    tokens: [
      { tokenId: 'token_i', display: 'I', role: 'S' as const },
      { tokenId: 'token_met', display: 'met', role: 'V' as const },
      { tokenId: 'token_friend', display: 'a friend', role: 'O' as const },
      { tokenId: 'token_yesterday', display: 'yesterday', role: 'M' as const },
    ],
    distractors: [
      { tokenId: 'token_the_friend', display: 'the friend', role: 'O' as const },
      { tokenId: 'token_today', display: 'today', role: 'M' as const },
    ],
    correctSequence: ['token_i', 'token_met', 'token_friend', 'token_yesterday'],
    patternTags: [tag],
    difficultyBand: 'core' as const,
    hints: [
      { order: 1, type: 'text' as const, content: '영어는 주어-동사 순서!' },
      { order: 2, type: 'slot-label' as const, content: '동사는 두 번째 슬롯' },
      { order: 3, type: 'highlight' as const, content: 'met 위치를 확인하세요' },
    ],
  }));
}

async function touchSession(sessionId: string) {
  await getFirestore().collection(SESSIONS_COLLECTION).doc(sessionId).set(
    {
      updatedAt: new Date().toISOString(),
    },
    { merge: true }
  );
}
