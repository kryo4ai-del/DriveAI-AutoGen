'use client';

import { Skill } from '@/types/skill';
import { getProgressColor } from '@/utils/skillColors';
import {
  getCompetenceLevel,
  getCompetenceLevelLabel,
  getAriaLabel,
} from '@/utils/competenceLevel';
import { ProgressBar } from './ProgressBar';

interface SkillCardProps {
  skill: Skill;
}

export function SkillCard({ skill }: SkillCardProps) {
  const level = getCompetenceLevel(skill.progress);
  const levelLabel = getCompetenceLevelLabel(level);
  const { badge, indicator } = getProgressColor(skill.progress);
  const ariaLabel = getAriaLabel(skill);

  return (
    <article
      className="bg-white rounded-lg shadow-md p-4 hover:shadow-lg transition-shadow duration-200"
      aria-label={`${skill.name} Skill Card`}
    >
      {/* Header */}
      <div className="flex items-start justify-between gap-3 mb-3">
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900">
            {skill.name}
          </h3>
          <p className="text-sm text-gray-500 mt-1">{skill.category}</p>
        </div>
        <span
          className={`text-xs font-medium px-2 py-1 rounded-full whitespace-nowrap ${badge}`}
        >
          <span aria-hidden="true">{indicator}</span> {levelLabel}
        </span>
      </div>

      {/* Progress Bar */}
      <div className="mb-3">
        <ProgressBar progress={skill.progress} ariaLabel={ariaLabel} />
      </div>

      {/* Stats */}
      <div className="flex items-center justify-between text-sm">
        <span className="font-bold text-gray-900">{skill.progress}%</span>
        <span className="text-gray-600">
          {skill.questionsCorrect}/{skill.questionsAttempted} richtig
        </span>
      </div>
    </article>
  );
}