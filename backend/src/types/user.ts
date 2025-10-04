import { PatternTrend } from './pattern';

export interface UserPreferences {
  hapticsEnabled: boolean;
  soundEnabled: boolean;
  pushOptIn: boolean;
  effectMode: 'full' | 'reduced' | 'minimal';
  dailyGoalSentences?: number;
  dailyGoalMinutes?: number;
}

export interface UserStats {
  currentStreak: number;
  longestStreak: number;
  brainTokens: number;
  streakFreezesAvailable: number;
  patternConquestCount: number;
  sessionsCompletedThisWeek: number;
  lastSessionAt: string | null;
  subscriptionStatus: 'free' | 'trial' | 'premium';
  brainBurstEligibleAt?: string | null;
  brainBurstMultiplier?: number | null;
  brainBurstActive?: boolean;
}

export interface UserFlags {
  levelTestCompleted: boolean;
  tutorialCompleted: boolean;
  personalizationReady: boolean;
  dataDeletionScheduled?: boolean;
  dataExportRequestedAt?: string | null;
}

export interface UserProfileDoc {
  userId: string;
  displayName: string;
  email: string;
  level: number;
  provisionalLevel: number;
  locale: string;
  timezone: string;
  preferences: UserPreferences;
  stats: UserStats;
  flags: UserFlags;
  createdAt: string;
  updatedAt: string;
}

export interface UserProfileUpdatePayload {
  displayName?: string;
  locale?: string;
  timezone?: string;
  preferences?: Partial<UserPreferences>;
}

export interface PatternCard {
  patternId: string;
  label: string;
  conquestRate: number;
  trend: PatternTrend;
  severity: number;
  recommendedAction: HomeAction;
}

export type HomeActionType =
  | 'daily-session'
  | 'review'
  | 'brain-burst'
  | 'widget'
  | 'tutorial';

export interface HomeAction {
  type: HomeActionType;
  title: string;
  subtitle?: string | null;
  deeplink: string;
  planRequired?: 'free' | 'pro';
}

export interface LiveActivityInfo {
  supported: boolean;
  active: boolean;
  activityId?: string | null;
  lastUpdatedAt?: string | null;
}

export interface HomeSummary {
  dailyGoal: {
    sentences: number;
    minutes: number;
    tier: 'basic' | 'intensive';
  };
  progress: {
    sentencesCompleted: number;
    minutesSpent: number;
    lastSessionAt: string | null;
  };
  streak: {
    current: number;
    longest: number;
    freezeEligible: boolean;
  };
  brainTokens: {
    available: number;
    pending: number;
  };
  patternCards: PatternCard[];
  recommendedActions: HomeAction[];
  liveActivity: LiveActivityInfo;
}

export interface WidgetSnapshot {
  updatedAt: string;
  sentencesRemaining: number;
  dailyGoalTier: 'basic' | 'intensive';
  currentStreak: number;
  brainTokens: number;
  nextBrainTokenInDays: number | null;
  deeplink: string;
}
