// Use union type instead of string to prevent Tailwind purge
export type CompetenceColor = 
  | 'bg-red-500' 
  | 'bg-yellow-500' 
  | 'bg-blue-500' 
  | 'bg-green-500';

export type CompetenceLevelId = 'beginner' | 'intermediate' | 'advanced' | 'expert';

export interface CompetenceLevel {
  id: CompetenceLevelId;
  name: string;
  color: CompetenceColor;
  minScore: number;
  maxScore: number;
}

export interface Competence {
  id: string;
  name: string;
  score: number; // 0–100
  level: CompetenceLevel;
}

export interface SkillMapState {
  data: SkillMapData | null;
  isLoading: boolean;
  error: string | null;
}