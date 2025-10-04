import {
  buildDefaultUserProfile,
  buildHomeSummary,
  deriveFlagsAfterSession,
  deriveStatsAfterSession,
} from '../src/services/userService';
import { UserProfileDoc } from '../src/types/user';
import { SessionSummary } from '../src/types/session';

describe('buildHomeSummary', () => {
  it('constructs summary with pattern cards and actions', () => {
    const user: UserProfileDoc = {
      userId: 'user-123',
      displayName: 'Test User',
      email: 'test@example.com',
      level: 2,
      provisionalLevel: 2,
      locale: 'ko-KR',
      timezone: 'Asia/Seoul',
      preferences: {
        hapticsEnabled: true,
        soundEnabled: true,
        pushOptIn: true,
        effectMode: 'full',
        dailyGoalSentences: 12,
        dailyGoalMinutes: 12,
      },
      stats: {
        currentStreak: 5,
        longestStreak: 7,
        brainTokens: 2,
        streakFreezesAvailable: 1,
        patternConquestCount: 3,
        sessionsCompletedThisWeek: 4,
        lastSessionAt: new Date().toISOString(),
        subscriptionStatus: 'free',
        brainBurstActive: true,
        brainBurstMultiplier: 2,
        brainBurstEligibleAt: new Date(Date.now() + 86400000).toISOString(),
      },
      flags: {
        levelTestCompleted: true,
        tutorialCompleted: true,
        personalizationReady: true,
        dataDeletionScheduled: false,
        dataExportRequestedAt: null,
      },
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const summary = buildHomeSummary(user);

    expect(summary.dailyGoal.sentences).toBe(12);
    expect(summary.progress.sentencesCompleted).toBeGreaterThan(0);
    expect(summary.patternCards.length).toBeGreaterThan(0);
    expect(summary.recommendedActions.length).toBeGreaterThan(0);
    expect(summary.liveActivity.supported).toBe(true);
  });
});

describe('buildDefaultUserProfile', () => {
  it('fills required defaults when optional data is missing', () => {
    const profile = buildDefaultUserProfile({
      uid: 'user-001',
      email: 'alpha@example.com',
    });

    expect(profile.userId).toBe('user-001');
    expect(profile.displayName).toBe('alpha');
    expect(profile.preferences.dailyGoalSentences).toBeGreaterThan(0);
    expect(profile.stats.subscriptionStatus).toBe('free');
    expect(profile.flags.levelTestCompleted).toBe(false);
  });
});

describe('deriveStatsAfterSession', () => {
  const baseSummary: SessionSummary = {
    accuracy: 0.85,
    totalItems: 12,
    correct: 10,
    incorrect: 2,
    hintsUsed: 1,
    comboMax: 4,
    brainTokensEarned: 2,
    durationSeconds: 780,
    patternImpact: [],
    completedAt: '2024-01-01T10:00:00.000Z',
  };

  it('initial session seeds streak, tokens, and weekly counters', () => {
    const profile = buildDefaultUserProfile({
      uid: 'user-seed',
      email: 'seed@example.com',
    });

    const stats = deriveStatsAfterSession(profile, baseSummary);

    expect(stats.currentStreak).toBe(1);
    expect(stats.longestStreak).toBe(1);
    expect(stats.sessionsCompletedThisWeek).toBe(1);
    expect(stats.brainTokens).toBe(profile.stats.brainTokens + baseSummary.brainTokensEarned);
    expect(stats.lastSessionAt).toBe(baseSummary.completedAt);
  });

  it('increments streak when session occurs on the next day in user timezone', () => {
    const profile = buildDefaultUserProfile({
      uid: 'user-streak',
      email: 'streak@example.com',
      timezone: 'Asia/Seoul',
    });
    profile.stats = {
      ...profile.stats,
      currentStreak: 3,
      longestStreak: 5,
      sessionsCompletedThisWeek: 3,
      brainTokens: 4,
      lastSessionAt: '2024-01-03T02:00:00.000Z',
    };

    const summary: SessionSummary = {
      ...baseSummary,
      completedAt: '2024-01-04T01:00:00.000Z',
      brainTokensEarned: 1,
    };

    const stats = deriveStatsAfterSession(profile, summary);

    expect(stats.currentStreak).toBe(4);
    expect(stats.longestStreak).toBe(5);
    expect(stats.sessionsCompletedThisWeek).toBe(4);
    expect(stats.brainTokens).toBe(5);
  });

  it('resets streak and weekly counter when gap exceeds a week boundary', () => {
    const profile = buildDefaultUserProfile({
      uid: 'user-reset',
      email: 'reset@example.com',
      timezone: 'UTC',
    });
    profile.stats = {
      ...profile.stats,
      currentStreak: 6,
      longestStreak: 9,
      sessionsCompletedThisWeek: 5,
      brainTokens: 10,
      lastSessionAt: '2024-01-01T08:00:00.000Z',
    };

    const summary: SessionSummary = {
      ...baseSummary,
      completedAt: '2024-01-10T12:00:00.000Z',
      brainTokensEarned: 3,
    };

    const stats = deriveStatsAfterSession(profile, summary);

    expect(stats.currentStreak).toBe(1);
    expect(stats.longestStreak).toBe(9);
    expect(stats.sessionsCompletedThisWeek).toBe(1);
    expect(stats.brainTokens).toBe(13);
  });
});

describe('deriveFlagsAfterSession', () => {
  it('sets personalization ready once pattern impact data exists', () => {
    const profile = buildDefaultUserProfile({
      uid: 'user-flag',
      email: 'flag@example.com',
    });

    const summary: SessionSummary = {
      accuracy: 0.9,
      totalItems: 12,
      correct: 11,
      incorrect: 1,
      hintsUsed: 0,
      comboMax: 5,
      brainTokensEarned: 1,
      durationSeconds: 600,
      patternImpact: [
        {
          patternId: 'time-adverb',
          deltaConquestRate: 0.1,
          exposures: 5,
        },
      ],
      completedAt: '2024-01-05T10:00:00.000Z',
    };

    const flags = deriveFlagsAfterSession(profile, summary);
    expect(flags.personalizationReady).toBe(true);
  });
});
