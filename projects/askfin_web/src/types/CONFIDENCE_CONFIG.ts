// In types/skillMap.ts
export const CONFIDENCE_CONFIG = {
  MINIMUM_SAMPLE: 30, // 30 answers = ~100% confidence
} as const;

// In services/competenceCalculator.ts
export class CompetenceCalculator {
  static calculateConfidence(answerCount: number): number {
    return Math.min(answerCount / CONFIDENCE_CONFIG.MINIMUM_SAMPLE, 1);
  }
}

// In services/skillMap.ts — use everywhere
// confidence: CompetenceCalculator.calculateConfidence(categoryAnswers.length)