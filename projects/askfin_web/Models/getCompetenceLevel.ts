import { CompetenceLevel } from '@/types/skill';

export function getCompetenceLevel(progress: number): CompetenceLevel {
  if (progress < 25) return 'beginner';
  if (progress < 50) return 'intermediate';
  if (progress < 75) return 'advanced';
  return 'expert';
}

export function getCompetenceLevelLabel(level: CompetenceLevel): string {
  const labels: Record<CompetenceLevel, string> = {
    beginner: 'Anfänger',
    intermediate: 'Mittelstufe',
    advanced: 'Fortgeschrittene',
    expert: 'Experte',
  };
  return labels[level];
}

export function getAriaLabel(skill: { name: string; progress: number }): string {
  const level = getCompetenceLevel(skill.progress);
  const label = getCompetenceLevelLabel(level);
  return `${skill.name}: ${label}, ${skill.progress}% Fortschritt`;
}