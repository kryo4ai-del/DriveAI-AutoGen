// components/ReadinessScore/ReadinessScore.tsx
'use client';

import { useEffect, useState } from 'react';
import { ReadinessScoreData } from '@/types/readiness';
import { useResponsive } from '@/hooks/useResponsive';
import { getScoreColor } from '@/utils/readinessHelpers';
import ScoreCounter from './ScoreCounter';
import MilestoneUnlock from './MilestoneUnlock';
import TrendArrow from './TrendArrow';
import MotivationalMessage from './MotivationalMessage';

interface ReadinessScoreProps {
  data: ReadinessScoreData;
  animated?: boolean;
  onAnimationComplete?: () => void;
}

export default function ReadinessScore({
  data,
  animated = true,
  onAnimationComplete,
}: ReadinessScoreProps) {
  const [isMounted, setIsMounted] = useState(false);
  const breakpoints = useResponsive();

  useEffect(() => {
    setIsMounted(true);
  }, []);

  if (!isMounted) {
    return (
      <div
        className="h-64 w-full bg-gradient-to-br from-gray-100 to-gray-50 rounded-2xl animate-pulse"
        role="status"
        aria-label="Loading readiness score"
      />
    );
  }

  const colorGradient = getScoreColor(data.score);
  const containerSize = breakpoints.lg ? 'p-8' : breakpoints.md ? 'p-6' : 'p-4';

  return (
    <section
      className={`${containerSize} bg-gradient-to-br ${colorGradient} rounded-2xl shadow-lg transition-all duration-300`}
      role="region"
      aria-label="Readiness Score Overview"
    >
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-8">
        {/* Score Section */}
        <div className="flex flex-col items-center justify-center">
          <ScoreCounter
            score={data.score}
            animated={animated}
            onAnimationComplete={onAnimationComplete}
          />
          <TrendArrow trend={data.trend} trendPercent={data.trendPercent} />
        </div>

        {/* Milestone & Message Section */}
        <div className="flex flex-col justify-between gap-6">
          {data.milestonesUnlocked.length > 0 && (
            <MilestoneUnlock milestones={data.milestonesUnlocked} />
          )}
          <MotivationalMessage score={data.score} />
        </div>
      </div>

      {/* Last Updated */}
      <p className="mt-6 text-center text-sm text-white/70">
        Last updated:{' '}
        <time dateTime={data.lastUpdated}>
          {new Date(data.lastUpdated).toLocaleDateString()}
        </time>
      </p>
    </section>
  );
}