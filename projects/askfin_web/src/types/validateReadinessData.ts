// utils/readiness-validation.ts

import { ReadinessData, ReadinessMilestone, ReadinessTrend } from '@/types/readiness';

/**
 * Validates ReadinessData structure, ranges, and consistency
 * @param data - Unknown data to validate
 * @returns true if valid ReadinessData
 */
export function validateReadinessData(data: unknown): data is ReadinessData {
  // Structural check
  if (!isValidStructure(data)) return false;

  const d = data as ReadinessData;

  // Range validation
  if (!isValidScoreRange(d.overallScore)) return false;
  if (!isValidMilestones(d.milestones)) return false;
  if (!isValidTimestamp(d.lastUpdated)) return false;

  // Consistency check: achieved milestones shouldn't exceed overall score
  if (!isConsistent(d)) return false;

  return true;
}

/**
 * Checks basic structure (type, required fields)
 */
function isValidStructure(data: unknown): data is Record<string, unknown> {
  if (!data || typeof data !== 'object') return false;

  const d = data as Record<string, unknown>;
  return (
    typeof d.overallScore === 'number' &&
    Array.isArray(d.milestones) &&
    typeof d.lastUpdated === 'string' &&
    Object.values(ReadinessTrend).includes(d.trend as ReadinessTrend)
  );
}

/**
 * Validates overall score is in valid range (0-100)
 */
function isValidScoreRange(score: unknown): score is number {
  return typeof score === 'number' && score >= 0 && score <= 100;
}

/**
 * Validates individual milestones
 */
function isValidMilestones(milestones: unknown): milestones is ReadinessMilestone[] {
  if (!Array.isArray(milestones)) return false;

  return milestones.every(m => {
    if (!m || typeof m !== 'object') return false;

    const milestone = m as Record<string, unknown>;
    return (
      typeof milestone.name === 'string' &&
      typeof milestone.threshold === 'number' &&
      milestone.threshold >= 0 &&
      milestone.threshold <= 100 &&
      typeof milestone.achieved === 'boolean' &&
      (milestone.achievedAt === undefined || typeof milestone.achievedAt === 'string')
    );
  });
}

/**
 * Validates ISO 8601 timestamp format
 */
function isValidTimestamp(timestamp: unknown): timestamp is string {
  if (typeof timestamp !== 'string') return false;
  return !isNaN(Date.parse(timestamp));
}

/**
 * Validates logical consistency:
 * Achieved milestones should have thresholds ≤ overall score
 */
function isConsistent(data: ReadinessData): boolean {
  const inconsistent = data.milestones.filter(
    m => m.achieved && m.threshold > data.overallScore
  );

  if (inconsistent.length > 0) {
    console.warn(
      '[ReadinessData] Inconsistent state detected: achieved milestones exceed overall score',
      { overall: data.overallScore, achieved: inconsistent }
    );
    return false;
  }

  return true;
}