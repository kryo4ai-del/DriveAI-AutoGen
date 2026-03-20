// services/readiness/types.ts
export interface ReadinessMetrics {
  training: number; // 0-100
  exams: number; // 0-100
  consistency: number; // 0-100
  coverage: number; // 0-100
}

export interface ReadinessScore {
  total: number; // 0-100
  breakdown: ReadinessMetrics;
  timestamp: Date;
}

export interface Milestone {
  id: string;
  threshold: number;
  label: string;
  unlockedAt?: Date;
  isUnlocked: boolean;
}

export interface TrendAnalysis {
  current: number;
  sevenDayAverage: number;
  sevenDayChange: number;
  trend: 'improving' | 'stable' | 'declining';
}

// ✅ NEW: Boundary normalizer
export function normalizeTrendData(raw: unknown[]): TrendData[] {
  if (!Array.isArray(raw)) {
    throw new Error('normalizeTrendData: expected array');
  }
  return raw.map((item: any, idx: number) => {
    if (typeof item.score !== 'number' || item.score < 0 || item.score > 100) {
      throw new Error(
        `normalizeTrendData[${idx}]: score must be 0-100, got ${item.score}`
      );
    }
    if (!item.timestamp) {
      throw new Error(`normalizeTrendData[${idx}]: missing timestamp`);
    }
    return {
      score: item.score,
      timestamp: typeof item.timestamp === 'string'
        ? new Date(item.timestamp)
        : item.timestamp,
    };
  });
}