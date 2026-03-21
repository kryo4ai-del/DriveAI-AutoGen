// types/skillMap.ts
export type SkillCategory = 
  | 'road_signs'
  | 'traffic_rules'
  | 'parking'
  | 'hazard_perception'
  | 'vehicle_handling'
  | 'legal_requirements';

export type CompetenceCategoryType = SkillCategory | 'overall';

export type CompetenceLevel = 'beginner' | 'intermediate' | 'advanced' | 'expert';

export interface CompetenceScore {
  category: CompetenceCategoryType; // ← Updated here only
  score: number;
  level: CompetenceLevel;
  accuracy: number;
  answerCount: number;
  confidence: number;
}