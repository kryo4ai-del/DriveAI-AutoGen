'use client';

import { SkillCategory } from '@/types/skillmap';
import { CompetenceIndicator } from './CompetenceIndicator';
import { getProgressBarColor, normalizeScore } from '@/utils/skillmap';

interface CategoryCompetenceCardProps {
  category: SkillCategory;
}

export function CategoryCompetenceCard({
  category,
}: CategoryCompetenceCardProps) {
  // Fixed bug #6: null safety
  const competences = category.competences || [];
  const progress = normalizeScore(category.overallProgress);

  return (
    <div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm hover:shadow-md transition-shadow">
      {/* Header */}
      <div className="mb-6">
        <h3 className="text-lg font-semibold text-gray-900">{category.name}</h3>
        <p className="text-sm text-gray-600">
          Overall Progress: {progress}%
        </p>
      </div>

      {/* Overall Progress Bar */}
      <div className="mb-6">
        <div
          className="h-2 bg-gray-100 rounded-full overflow-hidden"
          role="progressbar"
          aria-label={`${category.name} overall progress`}
          aria-valuenow={progress}
          aria-valuemin={0}
          aria-valuemax={100}
        >
          <div
            className={`h-full ${getProgressBarColor(progress)} transition-all duration-300`}
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>

      {/* Competences Grid */}
      {competences.length > 0 ? (
        <div className="space-y-4">
          {competences.map((competence) => (
            <div
              key={competence.id}
              className="flex items-center justify-between gap-4"
            >
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-900">
                  {competence.name}
                </p>
                <div
                  className="mt-1 h-1.5 bg-gray-100 rounded-full overflow-hidden"
                  role="progressbar"
                  aria-label={`${competence.name} progress`}
                  aria-valuenow={normalizeScore(competence.score)}
                  aria-valuemin={0}
                  aria-valuemax={100}
                >
                  <div
                    className={`h-full ${getProgressBarColor(competence.score)} transition-all duration-300`}
                    style={{ width: `${normalizeScore(competence.score)}%` }}
                  />
                </div>
              </div>
              <CompetenceIndicator competence={competence} size="sm" />
            </div>
          ))}
        </div>
      ) : (
        <p className="text-sm text-gray-500">No competences yet</p>
      )}
    </div>
  );
}