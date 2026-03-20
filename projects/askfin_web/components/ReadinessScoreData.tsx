// types/readiness.ts
'use strict';

export interface ReadinessScoreData {
  score: number;           // 0-100
  trend: 'up' | 'down' | 'stable';
  trendPercent?: number;   // e.g., +5, -2
  previousScore?: number;
  milestonesUnlocked: Milestone[];
  lastUpdated: string;
}

export interface ScoreBreakdown {
  category: string;
  percent: number;
  color: string;
}