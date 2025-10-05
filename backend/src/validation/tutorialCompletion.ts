import { ValidationError } from '../utils/errors';

export interface TutorialCompletionPayload {
  tutorialId: string;
  completedAt: string;
}

export function validateTutorialCompletionPayload(body: unknown): TutorialCompletionPayload {
  if (!body || typeof body !== 'object') {
    throw new ValidationError('Request body must be an object');
  }

  const { tutorialId, completedAt } = body as Partial<TutorialCompletionPayload>;

  if (typeof tutorialId !== 'string' || tutorialId.trim().length === 0) {
    throw new ValidationError('tutorialId is required');
  }

  if (!isValidIsoTimestamp(completedAt)) {
    throw new ValidationError('completedAt must be an ISO 8601 string');
  }

  return {
    tutorialId: tutorialId.trim(),
    completedAt,
  };
}

function isValidIsoTimestamp(value: unknown): value is string {
  if (typeof value !== 'string') {
    return false;
  }
  const parsed = Date.parse(value);
  return !Number.isNaN(parsed);
}
