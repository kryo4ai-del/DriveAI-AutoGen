// ✅ IMPROVED types.ts
export interface TrendData {
  score: number;
  timestamp: Date | string; // Accept both
}

// ✅ ADD normalizer at boundary
export function normalizeTrendData(raw: unknown[]): TrendData[] {
  return raw.map((item: any, idx: number) => {
    if (typeof item.score !== 'number' || item.score < 0 || item.score > 100) {
      throw new Error(`Item[${idx}]: invalid score ${item.score}`);
    }
    return {
      score: item.score,
      timestamp: typeof item.timestamp === 'string'
        ? new Date(item.timestamp)
        : item.timestamp,
    };
  });
}