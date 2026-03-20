'use client';

import React, { useEffect, useRef, useState } from 'react';
import { ReadinessCircleProps } from './types';

// Animation constants
const ANIMATION_FRAME_MS = 16; // ~60fps
const EASING_FACTOR = 0.1; // Smoothness (lower = smoother)
const COMPLETION_THRESHOLD = 0.5; // Pixel precision

// SVG bounds
const MIN_SIZE = 100;
const MAX_SIZE = 600;
const MIN_STROKE = 4;

export function ReadinessCircle({
  score,
  size = 280,
  strokeWidth = 12,
}: ReadinessCircleProps) {
  const [animatedScore, setAnimatedScore] = useState(0);
  const animatingRef = useRef(false);
  const scoreRef = useRef(score);

  // Validate and clamp inputs
  const validScore = Math.max(0, Math.min(100, score));
  const validSize = Math.max(MIN_SIZE, Math.min(MAX_SIZE, size));
  const validStroke = Math.max(MIN_STROKE, Math.min(validSize / 4, strokeWidth));

  // Update score ref when prop changes (for useRef access in animate)
  useEffect(() => {
    scoreRef.current = validScore;
  }, [validScore]);

  // Animation loop: runs once, uses ref to always target latest score
  useEffect(() => {
    animatingRef.current = true;

    const animate = () => {
      if (!animatingRef.current) return;

      setAnimatedScore((prev) => {
        const target = scoreRef.current;
        const diff = target - prev;

        if (Math.abs(diff) < COMPLETION_THRESHOLD) {
          animatingRef.current = false;
          return target;
        }

        return prev + diff * EASING_FACTOR;
      });

      if (animatingRef.current) {
        setTimeout(animate, ANIMATION_FRAME_MS);
      }
    };

    animate();

    return () => {
      animatingRef.current = false;
    };
  }, []); // Empty dependency: animation runs once, uses ref for updates

  const radius = Math.max(10, (validSize - validStroke) / 2);
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (animatedScore / 100) * circumference;

  const cx = validSize / 2;
  const cy = validSize / 2;

  const isHighScore = animatedScore > 75;

  return (
    <div className="flex items-center justify-center relative">
      <svg
        width={validSize}
        height={validSize}
        className="transform -rotate-90"
        role="img"
        aria-label={`${Math.round(animatedScore)}% readiness`}
      >
        {/* Background circle */}
        <circle
          cx={cx}
          cy={cy}
          r={radius}
          fill="none"
          stroke="#e5e7eb"
          strokeWidth={validStroke}
        />

        {/* Progress circle */}
        <circle
          cx={cx}
          cy={cy}
          r={radius}
          fill="none"
          stroke="#3b82f6"
          strokeWidth={validStroke}
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          strokeLinecap="round"
          className="transition-all duration-300"
          style={{
            filter: isHighScore
              ? 'drop-shadow(0 0 8px rgba(34, 197, 94, 0.5))'
              : 'none',
          }}
        />
      </svg>

      {/* Center content */}
      <div className="absolute flex flex-col items-center justify-center">
        <div className="text-5xl font-bold text-gray-900">
          {Math.round(animatedScore)}
        </div>
        <div className="text-sm font-medium text-gray-500">% Ready</div>
      </div>
    </div>
  );
}