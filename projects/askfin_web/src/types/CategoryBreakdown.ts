export interface CategoryBreakdown {
  category: string;
  correct: number;
  total: number;
  percentage: number; // 0–100, server-computed
}