Element: Animated SVG circle (motion.div with backgroundColor)
Issue: animation_safety
Severity: HIGH
Description: Circle expands/contracts every 50ms without checking prefers-reduced-motion. Users with vestibular disorders or motion sensitivity may experience dizziness or discomfort.
Recommendation: Respect user's motion preference.

Current code:
<motion.div
  animate={{ scale: scaleValue }}
  transition={{ duration: 0.05, ease: 'linear' }}
  className="relative w-40 h-40 rounded-full shadow-lg"
  style={{ backgroundColor: bgColor }}
/>

Fix:
'use client';

import { useEffect, useState } from 'react';

export function BreathingCircle({ phase, progress, timeRemaining }: BreathingCircleProps) {
  const [prefersReducedMotion, setPrefersReducedMotion] = useState(false);

  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    setPrefersReducedMotion(mediaQuery.matches);

    const handler = (e: MediaQueryListEvent) => setPrefersReducedMotion(e.matches);
    mediaQuery.addEventListener('change', handler);
    return () => mediaQuery.removeEventListener('change', handler);
  }, []);

  const scaleValue = useMemo(() => {
    if (phase === 'idle') return 1;
    if (phase === 'inhale') return 1 + progress * 0.4;
    if (phase === 'exhale') return 1.4 - progress * 0.4;
    return 1.4;
  }, [phase, progress]);

  return (
    <div className="flex flex-col items-center justify-center gap-8">
      <motion.div
        animate={{ scale: prefersReducedMotion ? 1 : scaleValue }}
        transition={{
          duration: prefersReducedMotion ? 0 : 0.05,
          ease: 'linear',
        }}
        className="relative w-40 h-40 rounded-full shadow-lg"
        style={{ backgroundColor: bgColor }}
      >
        {/* ... */}
      </motion.div>
    </div>
  );
}