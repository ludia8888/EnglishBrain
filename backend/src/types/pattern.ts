export type PatternFocus =
  | 'time-adverb'
  | 'frequency-adverb'
  | 'article'
  | 'preposition'
  | 'auxiliary'
  | 'tense'
  | 'clause';

export type PatternTrend = 'improving' | 'stable' | 'declining';

export interface PatternDefinition {
  patternId: string;
  label: string;
  description: string;
  focus: PatternFocus;
  example?: string;
}

export interface PatternConquest {
  patternId: string;
  label: string;
  conquestRate: number;
  severity: number;
  exposures: number;
  lastPracticedAt?: string | null;
  trend: PatternTrend;
  hintRate: number;
  firstTryRate: number;
}

export interface PatternImpactInput {
  patternId: string;
  correct: number;
  total: number;
  hintRate: number;
  firstTryRate: number;
  timestamp: string;
}
