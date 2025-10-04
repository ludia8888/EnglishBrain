import type { DocumentData } from 'firebase-admin/firestore';

import { getFirestore } from '../firebaseAdmin';
import {
  HomeAction,
  HomeSummary,
  PatternCard,
  UserFlags,
  UserProfileDoc,
  UserProfileUpdatePayload,
  UserStats,
  WidgetSnapshot,
} from '../types/user';
import { LevelTestResult } from '../types/levelTest';
import { SessionSummary } from '../types/session';

const USERS_COLLECTION = 'users';
const DEFAULT_LEVEL = 1;
const DEFAULT_LOCALE = 'ko-KR';
const DEFAULT_TIMEZONE = 'Asia/Seoul';
const DEFAULT_DISPLAY_NAME = 'Learner';
const DEFAULT_DAILY_GOAL_SENTENCES = 12;
const DEFAULT_DAILY_GOAL_MINUTES = 12;

export interface UserProfileDefaultsInput {
  uid: string;
  email?: string | null;
  displayName?: string | null;
  locale?: string | null;
  timezone?: string | null;
  provisionalLevel?: number | null;
  createdAt?: string | null;
}

export async function ensureUserProfile(input: UserProfileDefaultsInput): Promise<UserProfileDoc> {
  const docRef = getFirestore().collection(USERS_COLLECTION).doc(input.uid);
  const snapshot = await docRef.get();

  if (!snapshot.exists) {
    const profile = buildDefaultUserProfile(input);
    await docRef.set(profile);
    return profile;
  }

  const normalized = normalizeUserProfile(input.uid, snapshot.data());
  if (!normalized) {
    const profile = buildDefaultUserProfile(input);
    await docRef.set(profile);
    return profile;
  }

  await docRef.set(normalized, { merge: true });
  return normalized;
}

export async function applySessionCompletion(uid: string, summary: SessionSummary): Promise<UserProfileDoc> {
  const profile = await ensureUserProfile({ uid });
  const stats = deriveStatsAfterSession(profile, summary);
  const flags = deriveFlagsAfterSession(profile, summary);
  const updatedAt = new Date().toISOString();

  await getFirestore()
    .collection(USERS_COLLECTION)
    .doc(uid)
    .set(
      {
        stats,
        flags,
        updatedAt,
      },
      { merge: true }
    );

  return {
    ...profile,
    stats,
    flags,
    updatedAt,
  };
}

export async function applyLevelTestResult(uid: string, result: LevelTestResult): Promise<void> {
  const profile = await ensureUserProfile({ uid });
  const updatedFlags: UserFlags = {
    ...profile.flags,
    levelTestCompleted: true,
  };

  const updatedAt = new Date().toISOString();

  await getFirestore()
    .collection(USERS_COLLECTION)
    .doc(uid)
    .set(
      {
        provisionalLevel: result.recommendedLevel,
        flags: updatedFlags,
        updatedAt,
        levelTest: {
          lastResult: result,
          updatedAt,
        },
      },
      { merge: true }
    );
}

export async function getUserProfile(uid: string): Promise<UserProfileDoc | null> {
  const snapshot = await getFirestore().collection(USERS_COLLECTION).doc(uid).get();
  if (!snapshot.exists) {
    return null;
  }
  return normalizeUserProfile(uid, snapshot.data());
}

export async function updateUserProfile(
  uid: string,
  payload: UserProfileUpdatePayload
): Promise<UserProfileDoc | null> {
  await ensureUserProfile({ uid });
  const docRef = getFirestore().collection(USERS_COLLECTION).doc(uid);
  const updates = {
    ...payload,
    userId: uid,
    updatedAt: new Date().toISOString(),
  };
  await docRef.set(updates, { merge: true });
  const updated = await docRef.get();
  return normalizeUserProfile(uid, updated.data());
}

export function buildHomeSummary(user: UserProfileDoc): HomeSummary {
  const dailyGoalSentences = user.preferences.dailyGoalSentences ?? DEFAULT_DAILY_GOAL_SENTENCES;
  const dailyGoalMinutes = user.preferences.dailyGoalMinutes ?? DEFAULT_DAILY_GOAL_MINUTES;
  const tier = dailyGoalMinutes > 12 ? 'intensive' : 'basic';
  const sentencesCompleted = user.stats.sessionsCompletedThisWeek * dailyGoalSentences;
  const minutesSpent = user.stats.sessionsCompletedThisWeek * dailyGoalMinutes;
  const brainTokensPending = Math.max(0, 3 - user.stats.brainTokens);

  const patternCards = buildPatternCards(user);
  const recommendedActions = buildRecommendedActions(user, patternCards);

  return {
    dailyGoal: {
      sentences: dailyGoalSentences,
      minutes: dailyGoalMinutes,
      tier,
    },
    progress: {
      sentencesCompleted,
      minutesSpent,
      lastSessionAt: user.stats.lastSessionAt ?? null,
    },
    streak: {
      current: user.stats.currentStreak,
      longest: user.stats.longestStreak,
      freezeEligible: user.stats.streakFreezesAvailable > 0,
    },
    brainTokens: {
      available: user.stats.brainTokens,
      pending: brainTokensPending,
    },
    patternCards,
    recommendedActions,
    liveActivity: {
      supported: true,
      active: Boolean(user.stats.brainBurstActive),
      activityId: user.stats.brainBurstActive ? 'pending' : null,
      lastUpdatedAt: user.stats.lastSessionAt ?? null,
    },
  };
}

export async function getWidgetSnapshot(uid: string): Promise<WidgetSnapshot | null> {
  const profile = await getUserProfile(uid);
  if (!profile) {
    return null;
  }
  const summary = buildHomeSummary(profile);
  return {
    updatedAt: new Date().toISOString(),
    sentencesRemaining: Math.max(summary.dailyGoal.sentences - summary.progress.sentencesCompleted, 0),
    dailyGoalTier: summary.dailyGoal.tier,
    currentStreak: summary.streak.current,
    brainTokens: summary.brainTokens.available,
    nextBrainTokenInDays: profile.stats.brainBurstEligibleAt ? calculateDaysUntil(profile.stats.brainBurstEligibleAt) : null,
    deeplink: 'englishbrain://session',
  };
}

export function buildDefaultUserProfile(input: UserProfileDefaultsInput): UserProfileDoc {
  const now = new Date();
  const createdAt = input.createdAt ?? now.toISOString();
  const displayName = deriveDisplayName(input.displayName, input.email);
  return {
    userId: input.uid,
    displayName,
    email: input.email ?? '',
    level: DEFAULT_LEVEL,
    provisionalLevel: input.provisionalLevel ?? DEFAULT_LEVEL,
    locale: input.locale ?? DEFAULT_LOCALE,
    timezone: input.timezone ?? DEFAULT_TIMEZONE,
    preferences: {
      hapticsEnabled: true,
      soundEnabled: true,
      pushOptIn: false,
      effectMode: 'full',
      dailyGoalSentences: DEFAULT_DAILY_GOAL_SENTENCES,
      dailyGoalMinutes: DEFAULT_DAILY_GOAL_MINUTES,
    },
    stats: {
      currentStreak: 0,
      longestStreak: 0,
      brainTokens: 0,
      streakFreezesAvailable: 0,
      patternConquestCount: 0,
      sessionsCompletedThisWeek: 0,
      lastSessionAt: null,
      subscriptionStatus: 'free',
      brainBurstEligibleAt: null,
      brainBurstMultiplier: null,
      brainBurstActive: false,
    },
    flags: {
      levelTestCompleted: false,
      tutorialCompleted: false,
      personalizationReady: false,
      dataDeletionScheduled: false,
      dataExportRequestedAt: null,
    },
    createdAt,
    updatedAt: createdAt,
  };
}

function buildPatternCards(_user: UserProfileDoc): PatternCard[] {
  const basePatterns = [
    {
      patternId: 'time-adverb',
      label: '시간 부사',
    },
    {
      patternId: 'article',
      label: '관사',
    },
    {
      patternId: 'preposition',
      label: '전치사',
    },
  ];

  return basePatterns.map((pattern, index) => {
    const conquestRate = Math.min(1, 0.6 + index * 0.1);
    const trend: PatternCard['trend'] = index === 0 ? 'improving' : index === 1 ? 'stable' : 'declining';

    return {
      ...pattern,
      conquestRate,
      trend,
      severity: 3 + index,
      recommendedAction: {
        type: 'review',
        title: `${pattern.label} 집중 복습`,
        subtitle: trend === 'declining' ? '최근 정확도가 하락 중입니다.' : undefined,
        deeplink: `englishbrain://review/${pattern.patternId}`,
      },
    };
  });
}

function buildRecommendedActions(user: UserProfileDoc, patternCards: PatternCard[]): HomeAction[] {
  const actions: HomeAction[] = [];

  actions.push({
    type: 'daily-session',
    title: '오늘의 12문장 세션 시작',
    subtitle: `현재 스트릭 ${user.stats.currentStreak}일`,
    deeplink: 'englishbrain://session/warmup',
  });

  const weakestPattern = patternCards.find((card) => card.trend === 'declining');
  if (weakestPattern) {
    actions.push({
      type: 'review',
      title: `${weakestPattern.label} 패턴 복습`,
      subtitle: '정복률을 회복해보세요',
      deeplink: `englishbrain://review/${weakestPattern.patternId}`,
      planRequired: user.stats.subscriptionStatus === 'free' ? 'pro' : undefined,
    });
  }

  if (user.stats.brainBurstActive) {
    actions.push({
      type: 'brain-burst',
      title: 'Brain Burst 보너스 활성화 중!',
      subtitle: `보너스 배수 x${user.stats.brainBurstMultiplier ?? 2}`,
      deeplink: 'englishbrain://session/brainburst',
    });
  }

  return actions;
}

export function deriveStatsAfterSession(profile: UserProfileDoc, summary: SessionSummary): UserStats {
  const completedAt = summary.completedAt ?? new Date().toISOString();
  const timeZone = profile.timezone || 'UTC';
  const lastSessionAt = profile.stats.lastSessionAt;

  const dayDiff = lastSessionAt ? calculateDayDifference(lastSessionAt, completedAt, timeZone) : null;
  let currentStreak = profile.stats.currentStreak;
  if (dayDiff === null) {
    currentStreak = 1;
  } else if (dayDiff === 0) {
    currentStreak = Math.max(currentStreak, 1);
  } else if (dayDiff === 1) {
    currentStreak += 1;
  } else if (dayDiff > 1) {
    currentStreak = 1;
  }

  const longestStreak = Math.max(profile.stats.longestStreak, currentStreak);

  const currentWeekKey = getWeekStartKey(completedAt, timeZone);
  const previousWeekKey = lastSessionAt ? getWeekStartKey(lastSessionAt, timeZone) : null;
  const sessionsCompletedThisWeek = previousWeekKey === currentWeekKey
    ? profile.stats.sessionsCompletedThisWeek + 1
    : 1;

  const brainTokensEarned = Math.max(summary.brainTokensEarned ?? 0, 0);
  const brainTokens = Math.max(0, profile.stats.brainTokens + brainTokensEarned);

  const patternConquestCount = Math.max(
    profile.stats.patternConquestCount,
    summary.patternImpact?.length ?? 0
  );

  return {
    ...profile.stats,
    currentStreak,
    longestStreak,
    sessionsCompletedThisWeek,
    brainTokens,
    lastSessionAt: completedAt,
    brainBurstEligibleAt: summary.brainBurstEligibleAt ?? profile.stats.brainBurstEligibleAt ?? null,
    brainBurstMultiplier: summary.brainBurstMultiplier ?? profile.stats.brainBurstMultiplier ?? null,
    brainBurstActive: summary.brainBurstApplied ?? profile.stats.brainBurstActive ?? false,
    patternConquestCount,
  };
}

export function deriveFlagsAfterSession(profile: UserProfileDoc, summary: SessionSummary): UserFlags {
  const personalizationReady = profile.flags.personalizationReady || (summary.patternImpact?.length ?? 0) > 0;
  return {
    ...profile.flags,
    personalizationReady,
  };
}

function calculateDaysUntil(timestamp: string): number {
  const target = new Date(timestamp).getTime();
  const now = Date.now();
  const diff = target - now;
  if (diff <= 0) {
    return 0;
  }
  return Math.ceil(diff / (24 * 60 * 60 * 1000));
}

const MS_PER_DAY = 24 * 60 * 60 * 1000;

function calculateDayDifference(previousIso: string, currentIso: string, timeZone: string): number {
  const previousMidnight = getLocalMidnightMillis(previousIso, timeZone);
  const currentMidnight = getLocalMidnightMillis(currentIso, timeZone);
  return Math.round((currentMidnight - previousMidnight) / MS_PER_DAY);
}

function getWeekStartKey(timestamp: string, timeZone: string): string {
  const midnight = getLocalMidnightMillis(timestamp, timeZone);
  const dayOfWeek = new Date(midnight).getUTCDay();
  const offset = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
  const weekStart = midnight + offset * MS_PER_DAY;
  return formatDateKey(weekStart);
}

function getLocalMidnightMillis(timestamp: string, timeZone: string): number {
  const date = new Date(timestamp);
  const formatter = new Intl.DateTimeFormat('en-US', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  });
  const parts = formatter.formatToParts(date).reduce<Record<string, string>>((acc, part) => {
    if (part.type !== 'literal') {
      acc[part.type] = part.value;
    }
    return acc;
  }, {});

  const year = Number(parts.year);
  const month = Number(parts.month);
  const day = Number(parts.day);

  return Date.UTC(year, month - 1, day);
}

function formatDateKey(midnight: number): string {
  const date = new Date(midnight);
  const year = date.getUTCFullYear();
  const month = `${date.getUTCMonth() + 1}`.padStart(2, '0');
  const day = `${date.getUTCDate()}`.padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function normalizeUserProfile(uid: string, data: DocumentData | undefined): UserProfileDoc | null {
  if (!data) {
    return null;
  }
  const createdAt = typeof data.createdAt === 'string' ? data.createdAt : new Date().toISOString();
  const updatedAt = typeof data.updatedAt === 'string' ? data.updatedAt : createdAt;
  const preferences = data.preferences ?? {};
  const stats = data.stats ?? {};
  const flags = data.flags ?? {};

  return {
    userId: data.userId ?? uid,
    displayName: typeof data.displayName === 'string' && data.displayName.trim().length > 0
      ? data.displayName
      : deriveDisplayName(data.displayName, data.email),
    email: typeof data.email === 'string' ? data.email : '',
    level: typeof data.level === 'number' ? data.level : DEFAULT_LEVEL,
    provisionalLevel:
      typeof data.provisionalLevel === 'number'
        ? data.provisionalLevel
        : typeof data.level === 'number'
        ? data.level
        : DEFAULT_LEVEL,
    locale: typeof data.locale === 'string' ? data.locale : DEFAULT_LOCALE,
    timezone: typeof data.timezone === 'string' ? data.timezone : DEFAULT_TIMEZONE,
    preferences: {
      hapticsEnabled: preferences.hapticsEnabled ?? true,
      soundEnabled: preferences.soundEnabled ?? true,
      pushOptIn: preferences.pushOptIn ?? false,
      effectMode: preferences.effectMode ?? 'full',
      dailyGoalSentences: preferences.dailyGoalSentences ?? DEFAULT_DAILY_GOAL_SENTENCES,
      dailyGoalMinutes: preferences.dailyGoalMinutes ?? DEFAULT_DAILY_GOAL_MINUTES,
    },
    stats: {
      currentStreak: stats.currentStreak ?? 0,
      longestStreak: stats.longestStreak ?? 0,
      brainTokens: stats.brainTokens ?? 0,
      streakFreezesAvailable: stats.streakFreezesAvailable ?? 0,
      patternConquestCount: stats.patternConquestCount ?? 0,
      sessionsCompletedThisWeek: stats.sessionsCompletedThisWeek ?? 0,
      lastSessionAt: stats.lastSessionAt ?? null,
      subscriptionStatus: stats.subscriptionStatus ?? 'free',
      brainBurstEligibleAt: stats.brainBurstEligibleAt ?? null,
      brainBurstMultiplier: stats.brainBurstMultiplier ?? null,
      brainBurstActive: stats.brainBurstActive ?? false,
    },
    flags: {
      levelTestCompleted: flags.levelTestCompleted ?? false,
      tutorialCompleted: flags.tutorialCompleted ?? false,
      personalizationReady: flags.personalizationReady ?? false,
      dataDeletionScheduled: flags.dataDeletionScheduled ?? false,
      dataExportRequestedAt: flags.dataExportRequestedAt ?? null,
    },
    createdAt,
    updatedAt,
  };
}

function deriveDisplayName(displayName?: string | null, email?: string | null): string {
  if (typeof displayName === 'string' && displayName.trim().length > 0) {
    return displayName.trim();
  }
  if (typeof email === 'string' && email.includes('@')) {
    const candidate = email.split('@')[0];
    if (candidate.trim().length > 0) {
      return candidate.trim();
    }
  }
  return DEFAULT_DISPLAY_NAME;
}
