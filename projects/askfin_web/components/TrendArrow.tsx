// components/ReadinessScore/TrendArrow.tsx
'use client';

import { getTrendDisplay } from '@/utils/readinessHelpers';
import { useAnimationTrigger } from '@/hooks/useAnimationTrigger';

interface TrendArrowProps {
  trend: 'up' | 'down' | 'stable';
  trendPercent?: number;
}

export default function TrendArrow({ trend, trendPercent = 0 }: TrendArrowProps) {
  const display = getTrendDisplay(trend, trendPercent);
  const isAnimating = useAnimationTrigger({
    triggerValue: trend,
    delay: 300,
  });

  return (
    <div
      className={`mt-6 flex flex-col items-center gap-2 transition-all duration-500 ${
        isAnimating ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
      }`}
      role="status"
      aria-label={`Trend is ${trend}: ${display.label}`}
      aria-live="polite"
    >
      <div
        className={`text-4xl font-bold ${display.color} ${
          trend !== 'stable' ? 'animate-pulse' : ''
        }`}
      >
        {display.icon}
      </div>
      <div className={`text-sm font-semibold ${display.color}`}>
        {display.label}
      </div>
      <div className="text-white/70 text-xs">
        {trend === 'up' && 'Great progress!'}
        {trend === 'down' && 'Review recent topics'}
        {trend === 'stable' && 'Consistent performance'}
      </div>
    </div>
  );
}