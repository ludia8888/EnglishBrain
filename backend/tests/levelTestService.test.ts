import { validateLevelTestPayload } from '../src/validation/levelTest';

describe('validateLevelTestPayload', () => {
  const basePayload = {
    attempts: Array.from({ length: 10 }, (_, index) => ({
      itemId: `lesson-${index}`,
      selectedTokenIds: ['a', 'b'],
      timeSpentMs: 1000,
      hintsUsed: 0,
    })),
    startedAt: new Date(Date.now() - 60000).toISOString(),
    completedAt: new Date().toISOString(),
  };

  it('accepts valid payloads', () => {
    expect(() => validateLevelTestPayload(basePayload)).not.toThrow();
  });

  it('rejects payloads with insufficient attempts', () => {
    const payload = { ...basePayload, attempts: [] };
    expect(() => validateLevelTestPayload(payload as any)).toThrow();
  });

  it('rejects payloads with invalid attempt data', () => {
    const payload = {
      ...basePayload,
      attempts: [
        {
          itemId: '',
          selectedTokenIds: [],
          timeSpentMs: -1,
        },
      ],
    };
    expect(() => validateLevelTestPayload(payload as any)).toThrow();
  });
});
