export const DIFFICULTY_ORDER = [
  "easy",
  "medium", 
  "hard",
] as const;

export type DifficultyLevel = typeof DIFFICULTY_ORDER[number];

export function isHarder(a: DifficultyLevel, b: DifficultyLevel): boolean {
  return DIFFICULTY_ORDER.indexOf(a) > DIFFICULTY_ORDER.indexOf(b);
}