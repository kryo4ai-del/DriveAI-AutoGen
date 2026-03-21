'use client';

import { useState, useEffect, useRef } from 'react';

/**
 * Animates progress from 0 to target over duration
 * Uses useRef to persist startTime across re-renders
 */
export function useProgressAnimation(
  targetProgress: number,
  duration: number = 800
): number {
  const [animatedProgress, setAnimatedProgress] = useState(0);
  const startTimeRef = useRef<number | null>(null);

  useEffect(() => {
    let animationFrameId: number;

    const animate = (currentTime: number) => {
      if (startTimeRef.current === null) {
        startTimeRef.current = currentTime;
      }

      const elapsed = currentTime - startTimeRef.current;
      const progress = Math.min(
        (elapsed / duration) * targetProgress,
        targetProgress
      );

      setAnimatedProgress(progress);

      if (progress < targetProgress) {
        animationFrameId = requestAnimationFrame(animate);
      }
    };

    animationFrameId = requestAnimationFrame(animate);

    return () => {
      cancelAnimationFrame(animationFrameId);
      startTimeRef.current = null;
    };
  }, [targetProgress, duration]);

  return animatedProgress;
}