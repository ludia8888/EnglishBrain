import { calculateSessionSummary, scoreAttempt } from '../src/services/scoringService';
import { SessionDoc } from '../src/types/session';

describe('scoringService', () => {
  it('scores attempt with penalties and bonuses', () => {
    const result = scoreAttempt({
      attemptId: 'a1',
      itemId: 'item1',
      startedAt: new Date().toISOString(),
      completedAt: new Date().toISOString(),
      placements: [],
      verdict: 'correct',
      timeSpentMs: 5000,
      hintsUsed: 2,
      comboCount: 3,
      retryNumber: 0,
    });
    expect(result.accuracy).toBe(1);
    expect(result.score).toBeGreaterThan(0);
  });

  it('builds session summary from attempts', () => {
    const session: SessionDoc = {
      sessionId: 'sess_1',
      uid: 'user_1',
      mode: 'daily',
      status: 'pending',
      startedAt: new Date().toISOString(),
      expiresAt: new Date().toISOString(),
      source: 'online',
      phases: [],
      items: [
        {
          itemId: 'item1',
          prompt: { ko: '', enReference: '' },
          frame: { slots: [] },
          tokens: [],
          correctSequence: [],
          patternTags: ['time-adverb'],
          difficultyBand: 'core',
        },
      ],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const summary = calculateSessionSummary(session, [
      {
        attemptId: 'a1',
        itemId: 'item1',
        startedAt: new Date().toISOString(),
        completedAt: new Date().toISOString(),
        placements: [],
        verdict: 'correct',
        timeSpentMs: 2000,
        hintsUsed: 1,
        comboCount: 2,
        retryNumber: 0,
      },
    ]);

    expect(summary.totalItems).toBeGreaterThan(0);
    expect(summary.patternImpact.length).toBeGreaterThan(0);
    expect(summary.brainBurstApplied).toBe(false);
  });
});
