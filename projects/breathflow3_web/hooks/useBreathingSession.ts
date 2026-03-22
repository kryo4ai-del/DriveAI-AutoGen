'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import {
  BreathingTechniqueType,
  BreathingPhase,
  BREATHING_TECHNIQUES,
} from '@/types/BreathingTechnique';
import { recordSession } from '@/services/statsService';

interface UseBreathingSessionState {
  selectedTechnique: BreathingTechniqueType | null;
  isActive: boolean;
  currentPhase: BreathingPhase;
  progress: number; // 0-1 for current cycle
  timeRemaining: number; // seconds
  elapsedTime: number; // seconds
  sessionDuration: number; // seconds
}

export function useBreathingSession() {
  const [state, setState] = useState<UseBreathingSessionState>({
    selectedTechnique: null,
    isActive: false,
    currentPhase: 'idle',
    progress: 0,
    timeRemaining: 0,
    elapsedTime: 0,
    sessionDuration: 0,
  });

  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const phaseStartTimeRef = useRef<number>(0);
  const sessionStartTimeRef = useRef<number>(0);

  const selectTechnique = useCallback((techniqueId: BreathingTechniqueType) => {
    const technique = BREATHING_TECHNIQUES[techniqueId];
    setState((prev) => ({
      ...prev,
      selectedTechnique: techniqueId,
      sessionDuration: technique.duration,
      timeRemaining: technique.duration,
    }));
  }, []);

  const startSession = useCallback(() => {
    if (!state.selectedTechnique) return;

    sessionStartTimeRef.current = Date.now();
    phaseStartTimeRef.current = Date.now();

    setState((prev) => ({
      ...prev,
      isActive: true,
      currentPhase: 'inhale',
      elapsedTime: 0,
    }));
  }, [state.selectedTechnique]);

  const pauseSession = useCallback(() => {
    setState((prev) => ({
      ...prev,
      isActive: false,
    }));
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }
  }, []);

  const resumeSession = useCallback(() => {
    sessionStartTimeRef.current = Date.now() - state.elapsedTime * 1000;
    phaseStartTimeRef.current = Date.now();
    setState((prev) => ({
      ...prev,
      isActive: true,
    }));
  }, [state.elapsedTime]);

  const endSession = useCallback(async () => {
    setState((prev) => ({
      ...prev,
      isActive: false,
      currentPhase: 'idle',
      progress: 0,
      timeRemaining: prev.sessionDuration,
      elapsedTime: 0,
    }));

    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }

    // Record session
    if (state.selectedTechnique && state.elapsedTime > 0) {
      await recordSession({
        techniqueId: state.selectedTechnique,
        duration: state.elapsedTime,
        timestamp: new Date(),
      });
    }
  }, [state.selectedTechnique, state.elapsedTime]);

  // Main timer loop
  useEffect(() => {
    if (!state.isActive || !state.selectedTechnique) return;

    const technique = BREATHING_TECHNIQUES[state.selectedTechnique];
    const { cycle } = technique;

    intervalRef.current = setInterval(() => {
      const now = Date.now();
      const elapsedMs = now - sessionStartTimeRef.current;
      const elapsedSeconds = Math.floor(elapsedMs / 1000);

      // Check if session is complete
      if (elapsedSeconds >= state.sessionDuration) {
        endSession();
        return;
      }

      // Determine current phase and progress
      const phaseElapsedMs = now - phaseStartTimeRef.current;
      let currentPhase: BreathingPhase = 'inhale';
      let phaseDuration = cycle.inhale;
      let nextPhaseTime = cycle.inhale;

      if (phaseElapsedMs < cycle.inhale) {
        currentPhase = 'inhale';
        phaseDuration = cycle.inhale;
      } else if (phaseElapsedMs < cycle.inhale + cycle.hold) {
        currentPhase = 'hold';
        phaseDuration = cycle.hold;
      } else if (phaseElapsedMs < cycle.inhale + cycle.hold + cycle.exhale) {
        currentPhase = 'exhale';
        phaseDuration = cycle.exhale;
      } else if (cycle.holdAfterExhale && phaseElapsedMs < cycle.inhale + cycle.hold + cycle.exhale + cycle.holdAfterExhale) {
        currentPhase = 'hold';
        phaseDuration = cycle.holdAfterExhale;
      } else {
        // Cycle complete, reset
        phaseStartTimeRef.current = now;
        currentPhase = 'inhale';
        phaseDuration = cycle.inhale;
      }

      const phaseProgress = Math.min(phaseElapsedMs / phaseDuration, 1);
      const timeRemaining = Math.max(state.sessionDuration - elapsedSeconds, 0);

      setState((prev) => ({
        ...prev,
        currentPhase,
        progress: phaseProgress,
        timeRemaining,
        elapsedTime: elapsedSeconds,
      }));
    }, 50);

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [state.isActive, state.selectedTechnique, state.sessionDuration, endSession]);

  return {
    ...state,
    selectTechnique,
    startSession,
    pauseSession,
    resumeSession,
    endSession,
  };
}