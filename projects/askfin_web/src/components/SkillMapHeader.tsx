'use client';

import { SkillMapData } from '@/types/skillmap';
import { CompetenceIndicator } from './CompetenceIndicator';
import { COMPETENCE_LEVELS } from '@/utils/skillmap';

interface SkillMapHeaderProps {
  data: SkillMapData;
}

export function SkillMapHeader({ data }: SkillMapHeaderProps) {
  // Fixed bug #6: safe fallback
  const overallLevel = data.overallLevel || COMPETENCE_LEVELS.beginner;
  const overallCompetence = {
    id: 'overall',
    name: 'Overall',
    score: data.overallCompetence,
    level: overallLevel,
  };

  const lastUpdatedDate = new Date(data.lastUpdated).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });

  return (
    <div className="rounded-lg border border-gray-200 bg-gradient-to-br from-gray-50 to-gray-100 p-8">
      <div className="flex flex-col items-center gap-6 md:flex-row md:items-start">
        {/* Circular Indicator */}
        <div className="flex-shrink-0">
          <CompetenceIndicator competence={overallCompetence} size="lg" />
        </div>

        {/* Summary Stats */}
        <div className="flex-1 text-center md:text-left">
          <h2 className="text-3xl font-bold text-gray-900">
            Your Learning Progress
          </h2>
          <p className="mt-2 text-gray-600">
            You've mastered <strong>{overallLevel.name}</strong> level
            competencies. Keep practicing to reach the next level!
          </p>

          <div className="mt-6 grid grid-cols-2 gap-4 md:gap-6">
            <div>
              <p className="text-sm text-gray-600">Categories</p>
              <p className="text-2xl font-bold text-gray-900">
                {data.categories.length}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Last Updated</p>
              <p className="text-sm font-medium text-gray-900">
                {lastUpdatedDate}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}