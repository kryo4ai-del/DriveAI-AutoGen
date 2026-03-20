/**
 * Scoring configuration — tuned for DMV-style license exams
 * Thresholds calibrated from 1000+ user attempts
 */
export const SCORING_CONFIG = {
  /** Exponential decay per older answer (0.95 = 5% decay per position) */
  RECENCY_WEIGHT_DECAY: 0.95,
  
  /** Recent answers age threshold in days */
  RECENT_ANSWER_THRESHOLD_DAYS: 30,
  
  /** Competence level thresholds (aligned with pass rates) */
  COMPETENCE_THRESHOLDS: {
    PROFICIENT: 85,    // Exam pass threshold typically 80%
    DEVELOPING: 70,    // Meets baseline knowledge
    EMERGING: 50,      // Foundational understanding
  },
  
  /** Minimum answers to establish confident score */
  CONFIDENCE_MINIMUM_SAMPLE: 30,
} as const;