export type SessionMode = 'daily' | 'review' | 'brain-burst' | 'tutorial' | 'diagnostic';
export type SessionStatus = 'pending' | 'active' | 'completed' | 'abandoned';

export interface BrainBurstState {
  active: boolean;
  multiplier: number;
  eligibleAt?: string | null;
  sessionsUntilActivation?: number;
}

export interface SessionPhase {
  phaseId: string;
  label: string;
  phaseType: 'warm-up' | 'focus' | 'cool-down' | 'review' | 'challenge';
  order: number;
  targetSentences: number;
  targetDurationSeconds: number;
  itemIds: string[];
  comboRules: {
    base: number;
    bonusPerStreak: number;
  };
  checkpointStatus?: {
    reached: boolean;
    accuracy?: number;
    combosMax?: number;
    completedAt?: string;
  };
}

export interface FrameSlot {
  role: 'S' | 'V' | 'O' | 'M';
  label: string;
  optional: boolean;
}

export interface FrameToken {
  tokenId: string;
  display: string;
  role: 'S' | 'V' | 'O' | 'M';
  lemma?: string;
  audioUrl?: string | null;
}

export interface SessionItem {
  itemId: string;
  prompt: {
    ko: string;
    enReference: string;
    audioUrl?: string | null;
  };
  frame: {
    slots: FrameSlot[];
  };
  tokens: FrameToken[];
  distractors?: FrameToken[];
  correctSequence: string[];
  patternTags: string[];
  difficultyBand: 'intro' | 'core' | 'challenge';
  hints?: {
    order: number;
    type: 'text' | 'slot-label' | 'highlight' | 'reveal';
    content: string;
  }[];
}

export interface SessionSummary {
  accuracy: number;
  totalItems: number;
  correct: number;
  incorrect: number;
  hintsUsed: number;
  comboMax: number;
  brainTokensEarned: number;
  durationSeconds: number;
  patternImpact: Array<{
    patternId: string;
    deltaConquestRate: number;
    exposures: number;
    severityBefore?: number | null;
    severityAfter?: number | null;
    hintRateBefore?: number | null;
    hintRateAfter?: number | null;
  }>;
  hintRate?: number;
  firstTryRate?: number;
  completedAt?: string;
  brainBurstApplied?: boolean;
  brainBurstMultiplier?: number | null;
  brainBurstEligibleAt?: string | null;
}

export interface SessionDoc {
  sessionId: string;
  uid: string;
  mode: SessionMode;
  status: SessionStatus;
  startedAt: string;
  expiresAt: string;
  source: 'online' | 'offline';
  phases: SessionPhase[];
  items: SessionItem[];
  summary?: SessionSummary;
  brainBurst?: BrainBurstState;
  createdAt: string;
  updatedAt: string;
}

export interface SessionCreatePayload {
  mode: SessionMode;
  entryPoint: string;
  patternFocus?: string[];
  includeAudio?: boolean;
  seedSessionId?: string | null;
}

export interface SessionUpdatePayload {
  status: 'completed' | 'abandoned';
  summary: SessionSummary;
}

export interface CheckpointSubmissionPayload {
  checkpointId: string;
  phaseId: string;
  reachedAt: string;
  accuracy: number;
  comboMax: number;
  hintsUsed: number;
  durationSeconds: number;
  brainTokensEarned?: number;
  freezeConsumed?: boolean;
}

export type AttemptVerdict = 'correct' | 'incorrect' | 'corrected';

export interface AttemptSubmissionPayload {
  attemptId: string;
  itemId: string;
  startedAt: string;
  completedAt: string;
  placements: Array<{ slot: 'S' | 'V' | 'O' | 'M'; tokenId: string }>;
  verdict: AttemptVerdict;
  timeSpentMs: number;
  hintsUsed: number;
  comboCount: number;
  errors?: Array<{
    code:
      | 'missing-verb'
      | 'missing-object'
      | 'misplaced-modifier'
      | 'tense-mismatch'
      | 'article-error'
      | 'preposition-error'
      | 'auxiliary-error';
    message?: string;
    details?: Record<string, string>;
  }>;
  retryNumber?: number;
}
