'use client';

import { Competence } from '@/types/skillmap';
import { getLevelColor, normalizeScore } from '@/utils/skillmap';

interface CompetenceIndicatorProps {
  competence: Competence;
  size?: 'sm' | 'md' | 'lg';
}

// Dynamic radius per size (fixed bug #2)
const radiusMap = { sm: 18, md: 32, lg: 40 };
const sizeMap = {
  sm: { container: 'w-12 h-12', text: 'text-xs' },
  md: { container: 'w-16 h-16', text: 'text-sm' },
  lg: { container: 'w-20 h-20', text: 'text-base' },
};

export function CompetenceIndicator({
  competence,
  size = 'md',
}: CompetenceIndicatorProps) {
  const { container, text } = sizeMap[size];
  const radius = radiusMap[size];
  const circumference = 2 * Math.PI * radius;
  
  // Fixed bug #1: validate score
  const normalizedScore = normalizeScore(competence.score);
  const strokeDashoffset = circumference - (normalizedScore / 100) * circumference;
  const colorClass = getLevelColor(competence.level.id);

  return (
    <div
      className={`relative flex items-center justify-center ${container}`}
      role="progressbar"
      aria-label={`${competence.name}: ${normalizedScore}% proficiency at ${competence.level.name} level`}
      aria-valuenow={normalizedScore}
      aria-valuemin={0}
      aria-valuemax={100}
    >
      <svg
        viewBox="0 0 100 100"
        className="absolute inset-0 w-full h-full -rotate-90"
        aria-hidden="true"
      >
        {/* Background circle */}
        <circle
          cx="50"
          cy="50"
          r={radius}
          fill="none"
          stroke="#e5e7eb"
          strokeWidth="3"
        />
        {/* Progress circle */}
        <circle
          cx="50"
          cy="50"
          r={radius}
          fill="none"
          stroke="currentColor"
          strokeWidth="3"
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
          className={colorClass}
          strokeLinecap="round"
        />
      </svg>

      {/* Score display */}
      <div className={`flex flex-col items-center justify-center ${text}`}>
        <span className="font-bold text-gray-900">{normalizedScore}%</span>
        <span className="text-gray-500 text-xs">{competence.level.name}</span>
      </div>
    </div>
  );
}