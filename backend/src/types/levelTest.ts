export interface LevelTestLessonDoc {
  lessonId: string;
  level: number;
  prompt: {
    ko: string;
    en: string;
  };
  correctSequence: string[];
  tokenPool: string[];
  tags?: string[];
  levelTest?: boolean;
}

export interface LevelTestAttemptSubmission {
  itemId: string;
  selectedTokenIds: string[];
  timeSpentMs: number;
  hintsUsed?: number;
}

export interface LevelTestSubmissionPayload {
  attempts: LevelTestAttemptSubmission[];
  startedAt: string;
  completedAt: string;
}

export interface LevelTestResult {
  recommendedLevel: number;
  confidence: number;
  rationale: string;
  nextLessonId: string;
  unlocksReview?: boolean;
  needsSessionCalibration?: boolean;
}

export interface LevelTestSubmissionRecord {
  submissionId: string;
  uid: string;
  attempts: LevelTestAttemptSubmission[];
  startedAt: string;
  completedAt: string;
  createdAt: string;
  result: LevelTestResult & {
    accuracy: number;
    correct: number;
    total: number;
  };
}
