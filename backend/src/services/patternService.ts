import { PATTERN_DEFINITIONS, getPatternDefinition } from '../config/patterns';
import { PatternConquest, PatternDefinition, PatternImpactInput, PatternTrend } from '../types/pattern';

const EWMA_LAMBDA = 0.2;
const IMPROVING_THRESHOLD = 0.05;
const DECLINING_THRESHOLD = -0.05;

interface PatternAccumulator {
  definition: PatternDefinition;
  conquestRate: number;
  previousConquestRate?: number;
  exposures: number;
  hintRate: number;
  firstTryRate: number;
  lastPracticedAt?: string | null;
}

export function getPatternDefinitions(): PatternDefinition[] {
  return PATTERN_DEFINITIONS;
}

export function aggregatePatternConquests(entries: PatternImpactInput[]): PatternConquest[] {
  const sorted = [...entries].sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
  const map = new Map<string, PatternAccumulator>();

  sorted.forEach((entry) => {
    const definition = getPatternDefinition(entry.patternId) ?? {
      patternId: entry.patternId,
      label: entry.patternId,
      description: 'Custom pattern',
      focus: 'clause',
    };
    const total = entry.total || 1;
    const accuracy = total ? entry.correct / total : 0;

    const acc = map.get(entry.patternId) ?? {
      definition,
      conquestRate: accuracy,
      exposures: 0,
      hintRate: entry.hintRate,
      firstTryRate: entry.firstTryRate,
      lastPracticedAt: entry.timestamp,
    };

    if (map.has(entry.patternId)) {
      acc.previousConquestRate = acc.conquestRate;
      acc.conquestRate = ewma(acc.conquestRate, accuracy);
      acc.hintRate = ewma(acc.hintRate, entry.hintRate);
      acc.firstTryRate = ewma(acc.firstTryRate, entry.firstTryRate);
    }

    acc.exposures += total;
    acc.lastPracticedAt = entry.timestamp;
    map.set(entry.patternId, acc);
  });

  return Array.from(map.values()).map((acc) => {
    const conquestRate = clamp(acc.conquestRate, 0, 1);
    const prev = acc.previousConquestRate ?? conquestRate;
    const delta = conquestRate - prev;
    let trend: PatternTrend = 'stable';
    if (delta >= IMPROVING_THRESHOLD) {
      trend = 'improving';
    } else if (delta <= DECLINING_THRESHOLD) {
      trend = 'declining';
    }

    return {
      patternId: acc.definition.patternId,
      label: acc.definition.label,
      conquestRate,
      severity: calculateSeverity(conquestRate),
      exposures: acc.exposures,
      lastPracticedAt: acc.lastPracticedAt,
      trend,
      hintRate: clamp(acc.hintRate, 0, 1),
      firstTryRate: clamp(acc.firstTryRate, 0, 1),
    };
  });
}

export function getSamplePatternConquests(): PatternConquest[] {
  const now = Date.now();
  const entries: PatternImpactInput[] = [
    {
      patternId: 'time-adverb',
      correct: 8,
      total: 10,
      hintRate: 0.2,
      firstTryRate: 0.6,
      timestamp: new Date(now - 86400000).toISOString(),
    },
    {
      patternId: 'time-adverb',
      correct: 9,
      total: 10,
      hintRate: 0.15,
      firstTryRate: 0.7,
      timestamp: new Date(now).toISOString(),
    },
    {
      patternId: 'preposition',
      correct: 4,
      total: 10,
      hintRate: 0.5,
      firstTryRate: 0.3,
      timestamp: new Date(now - 2 * 86400000).toISOString(),
    },
  ];

  return aggregatePatternConquests(entries);
}

function ewma(previous: number, value: number) {
  return EWMA_LAMBDA * value + (1 - EWMA_LAMBDA) * previous;
}

function calculateSeverity(conquestRate: number) {
  return Math.min(5, Math.max(1, Math.round((1 - conquestRate) * 5)));
}

function clamp(value: number, min: number, max: number) {
  return Math.max(min, Math.min(max, value));
}
