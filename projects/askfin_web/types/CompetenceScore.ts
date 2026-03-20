// types/skillMap.ts
  | 'road_signs'
  | 'traffic_rules'
  | 'parking'
  | 'hazard_perception'
  | 'vehicle_handling'
  | 'legal_requirements';

export type CompetenceCategoryType = SkillCategory | 'overall';

export interface CompetenceScore {
  category: CompetenceCategoryType; // ← Updated here only
  score: number;
  level: CompetenceLevel;
  accuracy: number;
  answerCount: number;
  confidence: number;
}