// hooks/useExamTimer.ts
'use client';

import { useState, useEffect, useCallback, useRef } from 'react';

export interface UseExamTimerReturn {
  remainingSeconds: number;
  remainingMinutes: number;
  formattedTime: string;
  isTimeUp: boolean;
  isRunning: boolean;
  pause: () => void;
  resume: () => void;
  reset: (seconds: number) => void;
}

export function useExamTimer(
  initialSeconds: number,
  onTimeUp?: () => void
): UseExamTimerReturn {
  const [remainingSeconds, setRemainingSeconds] = useState(initialSeconds);
  const [isRunning, setIsRunning] = useState(true);
  const timeUpCalledRef = useRef(false);
  const onTimeUpRef = useRef(onTimeUp);

  // Keep callback ref in sync with prop
  useEffect(() => {
    onTimeUpRef.current = onTimeUp;
  }, [onTimeUp]);

  // Countdown effect—only depends on running state
  useEffect(() => {
    if (!isRunning || remainingSeconds <= 0) return;

    const intervalId = setInterval(() => {
      setRemainingSeconds((prev) => {
        const next = prev - 1;
        return next >= 0 ? next : 0;
      });
    }, 1000);

    return () => clearInterval(intervalId);
  }, [isRunning]);

  // Call onTimeUp when timer reaches zero—only depends on seconds
  useEffect(() => {
    if (remainingSeconds === 0 && !timeUpCalledRef.current) {
      timeUpCalledRef.current = true;
      setIsRunning(false);
      onTimeUpRef.current?.();
    }
  }, [remainingSeconds]);

  const pause = useCallback(() => {
    setIsRunning(false);
  }, []);

  const resume = useCallback(() => {
    if (remainingSeconds > 0) {
      setIsRunning(true);
    }
  }, [remainingSeconds]);

  const reset = useCallback((seconds: number) => {
    setRemainingSeconds(seconds);
    setIsRunning(true);
    timeUpCalledRef.current = false;
  }, []);

  const remainingMinutes = Math.floor(remainingSeconds / 60);
  const remainingSecondsInMinute = remainingSeconds % 60;
  const formattedTime = `${remainingMinutes.toString().padStart(2, '0')}:${remainingSecondsInMinute.toString().padStart(2, '0')}`;
  const isTimeUp = remainingSeconds === 0;

  return {
    remainingSeconds,
    remainingMinutes,
    formattedTime,
    isTimeUp,
    isRunning,
    pause,
    resume,
    reset,
  };
}