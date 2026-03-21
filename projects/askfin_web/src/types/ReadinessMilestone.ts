// types/readiness.ts

export enum ReadinessTrend {
  IMPROVING = 'IMPROVING',
  STABLE = 'STABLE',
  DECLINING = 'DECLINING',
}

export interface ReadinessMilestone {
  name: string;
  /** Threshold percentage (0-100) */
  threshold: number;
  achieved: boolean;
  /** ISO 8601 timestamp or undefined */
  achievedAt?: string;
}

/** Type guard for safe API parsing */