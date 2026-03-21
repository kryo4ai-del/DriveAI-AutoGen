// Discriminated union for milestone state (prevents impossible states)
export type MilestoneState = 
  | { status: 'achieved'; date: string }
  | { status: 'locked' }
  | { status: 'pending'; date: string };

export interface Milestone {
  id: string;
  name: string;
  state: MilestoneState;
  icon?: string;
}

export type TrendDirection = 'up' | 'down' | 'stable';

export interface ReadinessScreenProps {
  score: number;
  milestones: Milestone[];
  trend?: TrendDirection;
  trendPercentage?: number;
  motivationalMessage?: string;
  bgGradient?: string;
  onContinue: () => void;
}

export interface ReadinessCircleProps {
  score: number;
  size?: number;
  strokeWidth?: number;
}

export interface TrendBadgeProps {
  trend: TrendDirection;
  percentage: number;
  label?: string;
}

export interface MilestoneRowProps {
  name: string;
  state: MilestoneState;
  icon?: string;
}