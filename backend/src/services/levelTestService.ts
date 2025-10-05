import { getFirestore } from '../firebaseAdmin';
import {
  LevelTestLessonDoc,
  LevelTestSubmissionPayload,
  LevelTestResult,
  LevelTestSubmissionRecord,
} from '../types/levelTest';
import { ValidationError } from '../utils/errors';
import { generateId } from '../utils/id';
import { validateLevelTestPayload } from '../validation/levelTest';

import { applyLevelTestResult, ensureUserProfile } from './userService';

const LESSONS_COLLECTION = 'lessons';
const LEVEL_TESTS_COLLECTION = 'level_tests';
const LEVEL_TEST_RATE_LIMIT_WINDOW_MS = 24 * 60 * 60 * 1000; // 24 hours
const LEVEL_TEST_RATE_LIMIT_MAX_SUBMISSIONS = 2;

interface EvaluationSummary {
  result: LevelTestResult & {
    accuracy: number;
    correct: number;
    total: number;
  };
  lessons: Map<string, LevelTestLessonDoc>;
}

export async function submitLevelTest(uid: string, payload: LevelTestSubmissionPayload): Promise<LevelTestResult> {
  // Defensive validation in service layer as well
  validateLevelTestPayload(payload);

  await ensureUserProfile({ uid });
  await assertLevelTestRateLimit(uid);

  const evaluation = await evaluateSubmission(payload);
  const submissionId = generateId('lvltest');
  const createdAt = new Date().toISOString();

  const record: LevelTestSubmissionRecord = {
    submissionId,
    uid,
    attempts: payload.attempts,
    startedAt: payload.startedAt,
    completedAt: payload.completedAt,
    createdAt,
    result: evaluation.result,
  };

  const db = getFirestore();
  await db.collection(LEVEL_TESTS_COLLECTION).doc(submissionId).set(record);

  await applyLevelTestResult(uid, {
    recommendedLevel: evaluation.result.recommendedLevel,
    confidence: evaluation.result.confidence,
    rationale: evaluation.result.rationale,
    nextLessonId: evaluation.result.nextLessonId,
    unlocksReview: evaluation.result.unlocksReview,
    needsSessionCalibration: evaluation.result.needsSessionCalibration,
  });

  return evaluation.result;
}

async function assertLevelTestRateLimit(uid: string): Promise<void> {
  const windowStart = Date.now() - LEVEL_TEST_RATE_LIMIT_WINDOW_MS;
  const db = getFirestore();

  const recentSubmissions = await db
    .collection(LEVEL_TESTS_COLLECTION)
    .where('uid', '==', uid)
    .orderBy('createdAt', 'desc')
    .limit(LEVEL_TEST_RATE_LIMIT_MAX_SUBMISSIONS)
    .get();

  const submissionsWithinWindow = recentSubmissions.docs.filter((doc) => {
    const createdAt = doc.get('createdAt');
    if (typeof createdAt !== 'string') {
      return false;
    }
    const createdAtMs = Date.parse(createdAt);
    return !Number.isNaN(createdAtMs) && createdAtMs >= windowStart;
  });

  if (submissionsWithinWindow.length >= LEVEL_TEST_RATE_LIMIT_MAX_SUBMISSIONS) {
    throw new ValidationError('Level test submission limit reached. Please try again tomorrow.', 429);
  }
}

async function evaluateSubmission(payload: LevelTestSubmissionPayload): Promise<EvaluationSummary> {
  const lessonIds = Array.from(new Set(payload.attempts.map((attempt) => attempt.itemId)));
  const lessons = await fetchLessons(lessonIds);

  let correct = 0;
  let total = 0;
  let firstIncorrectLesson: string | null = null;
  let levelSum = 0;

  payload.attempts.forEach((attempt) => {
    total += 1;
    const lesson = lessons.get(attempt.itemId);
    if (!lesson) {
      if (!firstIncorrectLesson) {
        firstIncorrectLesson = attempt.itemId;
      }
      return;
    }
    const isCorrect = arraysEqual(attempt.selectedTokenIds, lesson.correctSequence);
    if (isCorrect) {
      correct += 1;
      levelSum += lesson.level;
    } else if (!firstIncorrectLesson) {
      firstIncorrectLesson = lesson.lessonId;
    }
  });

  const accuracy = total > 0 ? correct / total : 0;
  const averageLessonLevel = lessonIds.length > 0 ? lessonsAggregateLevel(lessons) / lessonIds.length : 1;
  const averageCorrectLevel = correct > 0 ? levelSum / correct : averageLessonLevel;

  const recommendedLevel = clampLevel(
    Math.round(
      accuracy >= 0.85
        ? averageCorrectLevel
        : accuracy >= 0.6
        ? (averageCorrectLevel + 1) / 2
        : Math.max(1, averageCorrectLevel - 1)
    )
  );

  const confidence = Number(accuracy.toFixed(2));
  const needsCalibration = accuracy < 0.85;
  const unlocksReview = accuracy >= 0.6;
  const fallbackLessonId = payload.attempts[0]?.itemId ?? '';
  const nextLessonId = firstIncorrectLesson ?? determineNextLesson(lessons, recommendedLevel) ?? fallbackLessonId;

  const rationale = `Accuracy ${(accuracy * 100).toFixed(0)}% across ${total} attempts. Recommended level ${recommendedLevel} computed from lesson difficulty.`;

  return {
    result: {
      recommendedLevel,
      confidence,
      rationale,
      nextLessonId,
      unlocksReview,
      needsSessionCalibration: needsCalibration,
      accuracy,
      correct,
      total,
    },
    lessons,
  };
}

async function fetchLessons(ids: string[]): Promise<Map<string, LevelTestLessonDoc>> {
  const db = getFirestore();
  const map = new Map<string, LevelTestLessonDoc>();
  await Promise.all(
    ids.map(async (id) => {
      const snapshot = await db.collection(LESSONS_COLLECTION).doc(id).get();
      if (snapshot.exists) {
        const data = snapshot.data() as LevelTestLessonDoc | undefined;
        if (data) {
          map.set(id, { ...data, lessonId: id });
        }
      }
    })
  );
  return map;
}

function arraysEqual(a: string[], b: string[]): boolean {
  if (a.length !== b.length) {
    return false;
  }
  return a.every((value, index) => value === b[index]);
}

function lessonsAggregateLevel(lessons: Map<string, LevelTestLessonDoc>): number {
  let sum = 0;
  lessons.forEach((lesson) => {
    sum += lesson.level;
  });
  return sum;
}

function determineNextLesson(lessons: Map<string, LevelTestLessonDoc>, recommendedLevel: number): string | null {
  const candidate = Array.from(lessons.values()).reduce<LevelTestLessonDoc | null>((best, lesson) => {
    if (!best) {
      return lesson;
    }
    const distanceBest = Math.abs(best.level - recommendedLevel);
    const distanceCurrent = Math.abs(lesson.level - recommendedLevel);
    return distanceCurrent < distanceBest ? lesson : best;
  }, null);
  return candidate ? candidate.lessonId : null;
}

function clampLevel(level: number): number {
  if (Number.isNaN(level) || !Number.isFinite(level)) {
    return 1;
  }
  return Math.min(5, Math.max(1, level));
}
