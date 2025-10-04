import { AttemptSubmissionPayload, SessionDoc, SessionSummary } from '../types/session';

const ORDER_WEIGHT = 0.6;
const FORM_WEIGHT = 0.25;
const POSITION_WEIGHT = 0.15;
const HINT_PENALTY = 0.1;
const COMBO_REWARD = 0.05;

export interface AttemptScore {
  score: number;
  accuracy: number;
  hintPenalty: number;
  comboBonus: number;
}

export function scoreAttempt(attempt: AttemptSubmissionPayload): AttemptScore {
  const baseAccuracy = attempt.verdict === 'correct' ? 1 : attempt.verdict === 'corrected' ? 0.7 : 0;
  const hintPenalty = attempt.hintsUsed * HINT_PENALTY;
  const comboBonus = attempt.comboCount * COMBO_REWARD;
  const weighted = ORDER_WEIGHT * baseAccuracy + FORM_WEIGHT * baseAccuracy + POSITION_WEIGHT * baseAccuracy;
  const score = Math.max(0, weighted - hintPenalty + comboBonus);
  return {
    score,
    accuracy: baseAccuracy,
    hintPenalty,
    comboBonus,
  };
}

export function calculateSessionSummary(session: SessionDoc, attempts: AttemptSubmissionPayload[]): SessionSummary {
  const totalItems = session.items.length;
  const correctAttempts = attempts.filter((a) => a.verdict === 'correct').length;
  const incorrectAttempts = attempts.filter((a) => a.verdict === 'incorrect').length;
  const hintsUsed = attempts.reduce((sum, a) => sum + a.hintsUsed, 0);
  const comboMax = Math.max(0, ...attempts.map((a) => a.comboCount));
  const durationSeconds = attempts.reduce((sum, a) => sum + Math.floor(a.timeSpentMs / 1000), 0);
  const firstTryCorrect = attempts.filter((a) => a.retryNumber === 0 && a.verdict === 'correct').length;
  const totalAttempts = attempts.length || 1;

  return {
    accuracy: totalItems ? correctAttempts / totalItems : 0,
    totalItems,
    correct: correctAttempts,
    incorrect: incorrectAttempts,
    hintsUsed,
    comboMax,
    brainTokensEarned: 0,
    durationSeconds,
    patternImpact: buildPatternImpact(session),
    hintRate: hintsUsed / totalAttempts,
    firstTryRate: firstTryCorrect / totalAttempts,
    completedAt: new Date().toISOString(),
    brainBurstApplied: session.brainBurst?.active ?? false,
    brainBurstMultiplier: session.brainBurst?.multiplier ?? null,
    brainBurstEligibleAt: session.brainBurst?.eligibleAt ?? null,
  };
}

function buildPatternImpact(session: SessionDoc) {
  return session.items.slice(0, 3).map((item, index) => ({
    patternId: item.patternTags[0] ?? `pattern_${index}`,
    deltaConquestRate: 0.05,
    exposures: 1,
    severityBefore: 3,
    severityAfter: 2,
    hintRateBefore: 0.3,
    hintRateAfter: 0.2,
  }));
}
