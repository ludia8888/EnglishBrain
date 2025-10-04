import { PatternDefinition } from '../types/pattern';

export const PATTERN_DEFINITIONS: PatternDefinition[] = [
  {
    patternId: 'time-adverb',
    label: '시간 부사',
    description: '시간 부사의 위치(문장 끝/시작)에 익숙해지기',
    focus: 'time-adverb',
    example: 'I met a friend yesterday.',
  },
  {
    patternId: 'frequency-adverb',
    label: '빈도 부사',
    description: '빈도 부사의 위치와 강조형 학습',
    focus: 'frequency-adverb',
    example: 'She usually exercises in the morning.',
  },
  {
    patternId: 'article',
    label: '관사',
    description: 'a/an/the 관사 선택 훈련',
    focus: 'article',
    example: 'He adopted a dog from the shelter.',
  },
  {
    patternId: 'preposition',
    label: '전치사',
    description: '전치사의 올바른 조합과 위치',
    focus: 'preposition',
    example: 'She put the book on the table.',
  },
  {
    patternId: 'auxiliary',
    label: '조동사',
    description: '조동사 사용과 어순 학습',
    focus: 'auxiliary',
    example: 'Can you help me?',
  },
  {
    patternId: 'tense',
    label: '시제',
    description: '시제 변화와 조합 이해',
    focus: 'tense',
    example: 'They have finished their homework.',
  },
  {
    patternId: 'clause',
    label: '절/구문',
    description: '명사절/형용사절/분사구문 등 확장 구조',
    focus: 'clause',
    example: 'The book that I read was fascinating.',
  },
];

export function getPatternDefinition(patternId: string) {
  return PATTERN_DEFINITIONS.find((pattern) => pattern.patternId === patternId);
}
