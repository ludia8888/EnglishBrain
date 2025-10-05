import { LevelTestAttemptSubmission, LevelTestSubmissionPayload } from '../types/levelTest';
import { ValidationError } from '../utils/errors';

export function validateLevelTestPayload(payload: LevelTestSubmissionPayload): void {
  if (!payload) {
    throw new ValidationError('Missing submission payload');
  }

  if (!Array.isArray(payload.attempts)) {
    throw new ValidationError('attempts must be an array');
  }

  if (payload.attempts.length < 10 || payload.attempts.length > 15) {
    throw new ValidationError('Level test must include between 10 and 15 attempts');
  }

  payload.attempts.forEach((attempt: LevelTestAttemptSubmission, index) => {
    if (typeof attempt.itemId !== 'string' || attempt.itemId.trim().length === 0) {
      throw new ValidationError(`Attempt ${index} missing itemId`);
    }

    if (!Array.isArray(attempt.selectedTokenIds) || attempt.selectedTokenIds.length === 0) {
      throw new ValidationError(`Attempt ${index} missing selectedTokenIds`);
    }

    if (typeof attempt.timeSpentMs !== 'number' || Number.isNaN(attempt.timeSpentMs) || attempt.timeSpentMs < 0) {
      throw new ValidationError(`Attempt ${index} has invalid timeSpentMs`);
    }

    if (
      attempt.hintsUsed !== undefined &&
      (typeof attempt.hintsUsed !== 'number' || attempt.hintsUsed < 0 || !Number.isFinite(attempt.hintsUsed))
    ) {
      throw new ValidationError(`Attempt ${index} has invalid hintsUsed`);
    }
  });

  if (!isValidIsoTimestamp(payload.startedAt)) {
    throw new ValidationError('startedAt must be an ISO 8601 string');
  }

  if (!isValidIsoTimestamp(payload.completedAt)) {
    throw new ValidationError('completedAt must be an ISO 8601 string');
  }
}

function isValidIsoTimestamp(value: unknown): value is string {
  if (typeof value !== 'string') {
    return false;
  }
  const parsed = Date.parse(value);
  return !Number.isNaN(parsed);
}
