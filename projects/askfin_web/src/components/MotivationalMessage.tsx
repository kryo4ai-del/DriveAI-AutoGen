// components/ReadinessScore/MotivationalMessage.tsx
'use client';

import { getMotivationalMessage } from '@/utils/readinessHelpers';
import { useAnimationTrigger } from '@/hooks/useAnimationTrigger';

interface MotivationalMessageProps {
  score: number;
}

export default function MotivationalMessage({
  score,
}: MotivationalMessageProps) {
  const message = getMotivationalMessage(score);
  const isAnimating = useAnimationTrigger({
    triggerValue: score,
    delay: 800,
  });

  return (
    <div
      className={`bg-white/10 backdrop-blur-sm rounded-xl p-5 border border-white/20 transition-all duration-700 transform ${
        isAnimating
          ? 'scale-100 opacity-100'
          : 'scale-95 opacity-0'
      }`}
      role="complementary"
      aria-label="Motivational message"
    >
      <div className="flex items-start gap-3">
        <span
          className="text-3xl flex-shrink-0"
          aria-hidden="true"
        >
          {message.emoji}
        </span>
        <div className="flex-1 min-w-0">
          <h4 className="text-white font-bold text-base lg:text-lg leading-tight">
            {message.primary}
          </h4>
          <p className="text-white/80 text-sm mt-2 leading-relaxed">
            {message.secondary}
          </p>
        </div>
      </div>

      {/* Progress indicator line */}
      <div className="mt-4 h-1 bg-white/10 rounded-full overflow-hidden">
        <div
          className="h-full bg-gradient-to-r from-white/60 to-white/20 rounded-full transition-all duration-1000"
          style={{
            width: `${Math.max(score, 20)}%`,
          }}
          aria-hidden="true"
        />
      </div>
    </div>
  );
}