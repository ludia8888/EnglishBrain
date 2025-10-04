import { aggregatePatternConquests, getPatternDefinitions } from '../src/services/patternService';
import { PatternImpactInput } from '../src/types/pattern';

describe('patternService', () => {
  it('returns pattern definitions', () => {
    const defs = getPatternDefinitions();
    expect(defs.length).toBeGreaterThan(0);
    expect(defs[0]).toHaveProperty('patternId');
  });

  it('aggregates pattern conquest metrics with EWMA', () => {
    const now = Date.now();
    const entries: PatternImpactInput[] = [
      {
        patternId: 'time-adverb',
        correct: 8,
        total: 10,
        hintRate: 0.3,
        firstTryRate: 0.5,
        timestamp: new Date(now - 86400000).toISOString(),
      },
      {
        patternId: 'time-adverb',
        correct: 9,
        total: 10,
        hintRate: 0.2,
        firstTryRate: 0.65,
        timestamp: new Date(now).toISOString(),
      },
    ];

    const result = aggregatePatternConquests(entries);
    expect(result.length).toBe(1);
    expect(result[0].conquestRate).toBeGreaterThan(0.5);
    expect(['improving', 'stable']).toContain(result[0].trend);
  });
});
