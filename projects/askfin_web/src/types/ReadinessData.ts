export interface ReadinessData {
  overallScore: number;  // 0-100
  /** At least one milestone required */
  milestones: ReadinessMilestone[];
  trend: ReadinessTrend;
  lastUpdated: string;
}