'use client';

import React, { useEffect, useRef, useState } from 'react';

// Add motion detection hook
function useReducedMotion() {
  const [prefersReduced, setPrefersReduced] = useState(false);

  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    setPrefersReduced(mediaQuery.matches);

    const listener = (event: MediaQueryListEvent) => {
      setPrefersReduced(event.matches);
    };

    mediaQuery.addEventListener('change', listener);
    return () => mediaQuery.removeEventListener('change', listener);
  }, []);

  return prefersReduced;
}

export function ReadinessCircle({
  score,
  size = 280,
  strokeWidth = 12,
}: ReadinessCircleProps) {
  const prefersReduced = useReducedMotion();
  
  // If reduced motion, jump directly to score (no animation)
  const [animatedScore, setAnimatedScore] = useState(
    prefersReduced ? score : 0
  );

  useEffect(() => {
    scoreRef.current = validScore;
  }, [validScore]);

  useEffect(() => {
    // Skip animation if prefers-reduced-motion
    if (prefersReduced) {
      setAnimatedScore(scoreRef.current);
      return;
    }

    animatingRef.current = true;
    const animate = () => { /* existing animation */ };
    animate();

    return () => { animatingRef.current = false; };
  }, [prefersReduced]); // Add prefersReduced dependency