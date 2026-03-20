export enum QuestionCategory {
  VORFAHRT = "VORFAHRT",
  VERKEHRSZEICHEN = "VERKEHRSZEICHEN",
  TECHNIK = "TECHNIK",
  VERHALTEN = "VERHALTEN",
  SICHERHEIT = "SICHERHEIT",
  UMWELT = "UMWELT",
  ERSTE_HILFE = "ERSTE_HILFE",
}

export const CATEGORY_LABELS: Record<QuestionCategory, string> = {
  [QuestionCategory.VORFAHRT]: "Right of Way",
  [QuestionCategory.VERKEHRSZEICHEN]: "Traffic Signs",
  [QuestionCategory.TECHNIK]: "Vehicle Technology",
  [QuestionCategory.VERHALTEN]: "Driving Behavior",
  [QuestionCategory.SICHERHEIT]: "Safety",
  [QuestionCategory.UMWELT]: "Environment",
  [QuestionCategory.ERSTE_HILFE]: "First Aid",
};