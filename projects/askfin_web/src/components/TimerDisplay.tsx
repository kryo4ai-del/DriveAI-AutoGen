'use client';

import type { TimerState } from '@/app/exam-simulation/types/exam';

interface TimerDisplayProps {
  timer: TimerState;
  ariaLabel?: string;
}

export function TimerDisplay({ timer, ariaLabel }: TimerDisplayProps) {
  const minutes = Math.floor(timer.remaining / 60);
  const seconds = timer.remaining % 60;

  const bgColor = timer.isPulsing
    ? 'bg-red-50 dark:bg-red-950'
    : 'bg-blue-50 dark:bg-blue-950';

  const textColor = timer.isPulsing
    ? 'text-red-900 dark:text-red-100'
    : 'text-blue-900 dark:text-blue-100';

  const borderColor = timer.isPulsing
    ? 'border-red-300 dark:border-red-700'
    : 'border-blue-200 dark:border-blue-800';

  return (
    <div
      className={`
        inline-flex items-center justify-center
        px-3 sm:px-4 py-2 rounded-lg font-mono font-bold
        border-2 text-sm sm:text-base
        ${bgColor} ${textColor} ${borderColor}
        transition-all duration-300
        ${timer.isPulsing ? 'animate-pulse shadow-lg shadow-red-200 dark:shadow-red-900' : ''}
      `}
      role="timer"
      aria-label={
        ariaLabel ||
        `Time remaining: ${minutes} minute${minutes !== 1 ? 's' : ''} ${seconds} second${seconds !== 1 ? 's' : ''}`
      }
      aria-live="polite"
      aria-atomic="true"
    >
      <span>
        {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}
      </span>
    </div>
  );
}