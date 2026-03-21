// components/ReadinessScore/ScoreCounter.tsx
'use client';

import { useCountUp } from '@/hooks/useCountUp';
import { useAnimationTrigger } from '@/hooks/useAnimationTrigger';

interface ScoreCounterProps {
  score: number;
  animated?: boolean;
  onAnimationComplete?: () => void;
}

export default function ScoreCounter({
  score,
  animated = true,
  onAnimationComplete,
}: ScoreCounterProps) {
  const countedScore = useCountUp({
    end: score,
    duration: 1200,
    enabled: animated,
  });

  const isAnimating = useAnimationTrigger({
    triggerValue: score,
    delay: 100,
  });

  // Trigger callback after animation
  if (animated && !isAnimating && onAnimationComplete) {
    onAnimationComplete();
  }

  return (
    <div className="text-center">
      <div
        className={`text-7xl lg:text-8xl font-black text-white drop-shadow-lg transition-all duration-500 ${
          isAnimating ? 'scale-100 opacity-100' : 'scale-95 opacity-75'
        }`}
        role="status"
        aria-label={`Your readiness score is ${countedScore} out of 100`}
        aria-live="polite"
      >
        {countedScore}
      </div>
      <div className="text-white/90 text-lg font-semibold mt-2">
        Readiness Score
      </div>
      <div className="text-white/70 text-sm mt-1">out of 100</div>

      {/* Progress bar */}
      <div className="mt-4 w-full max-w-xs mx-auto bg-white/20 rounded-full h-3 overflow-hidden">
        <div
          className="h-full bg-white/80 rounded-full transition-all duration-1000 ease-out"
          style={{ width: `${countedScore}%` }}
          role="progressbar"
          aria-valuenow={countedScore}
          aria-valuemin={0}
          aria-valuemax={100}
          aria-label="Score progress"
        />
      </div>
    </div>
  );
}