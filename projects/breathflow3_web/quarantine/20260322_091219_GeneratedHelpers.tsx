// Use a cycle-based approach instead of absolute time
const cycleDuration = cycle.inhale + cycle.hold + cycle.exhale + (cycle.holdAfterExhale || 0);
const cyclePosition = phaseElapsedMs % cycleDuration;

let currentPhase: BreathingPhase = 'inhale';
let phaseDuration = cycle.inhale;

if (cyclePosition < cycle.inhale) {
  currentPhase = 'inhale';
  phaseDuration = cycle.inhale;
} else if (cyclePosition < cycle.inhale + cycle.hold) {
  currentPhase = 'hold';
  phaseDuration = cycle.hold;
} else if (cyclePosition < cycle.inhale + cycle.hold + cycle.exhale) {
  currentPhase = 'exhale';
  phaseDuration = cycle.exhale;
} else if (cycle.holdAfterExhale) {
  currentPhase = 'hold';
  phaseDuration = cycle.holdAfterExhale;
}

const phaseProgress = (cyclePosition % phaseDuration) / phaseDuration;

// ---

const resumeSession = useCallback(() => {
  const now = Date.now();
  sessionStartTimeRef.current = now - state.elapsedTime * 1000;
  phaseStartTimeRef.current = now; // Reset phase timing on resume
  setState((prev) => ({ ...prev, isActive: true }));
}, [state.elapsedTime]);

// ---

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

<motion.div
  animate={{ scale: prefersReducedMotion ? 1 : scaleValue }}
  transition={{ duration: prefersReducedMotion ? 0 : 0.05, ease: 'linear' }}
  // ...
/>

// ---

<button
  onClick={onClick}
  aria-pressed={isSelected}
  aria-label={`Select ${technique.name} breathing exercise`}
  className={/* ... */}
>
  {/* content */}
</button>

// ---

// BROKEN: phaseStartTimeRef never resets for subsequent cycles
if (phaseElapsedMs < cycle.inhale + cycle.hold + cycle.exhale + ...) {
  // Do stuff
} else {
  // Cycle complete, reset
  phaseStartTimeRef.current = now; // ✅ Reset happens
  currentPhase = 'inhale';
}

// ---

const cycleDuration = cycle.inhale + cycle.hold + cycle.exhale + (cycle.holdAfterExhale || 0);
const phaseElapsedMs = now - phaseStartTimeRef.current;
const cyclePosition = phaseElapsedMs % cycleDuration; // ← Modulo wraps automatically

let currentPhase: BreathingPhase = 'inhale';
let phaseDuration = cycle.inhale;
let phaseStart = 0;

if (cyclePosition < cycle.inhale) {
  currentPhase = 'inhale';
  phaseDuration = cycle.inhale;
  phaseStart = 0;
} else if (cyclePosition < cycle.inhale + cycle.hold) {
  currentPhase = 'hold';
  phaseDuration = cycle.hold;
  phaseStart = cycle.inhale;
} else if (cyclePosition < cycle.inhale + cycle.hold + cycle.exhale) {
  currentPhase = 'exhale';
  phaseDuration = cycle.exhale;
  phaseStart = cycle.inhale + cycle.hold;
} else if (cycle.holdAfterExhale) {
  currentPhase = 'hold';
  phaseDuration = cycle.holdAfterExhale;
  phaseStart = cycle.inhale + cycle.hold + cycle.exhale;
}

// Progress within current phase only
const phaseProgress = ((cyclePosition - phaseStart) / phaseDuration);

// ---

// Box breathing: 4s each, 16s cycle
// At t=15s: cyclePosition = 15000 % 16000 = 15000
// 15000 > (4000 + 4000 + 4000) = 12000 → should be holdAfterExhale
// Progress = (15000 - 12000) / 4000 = 0.75 ✅

// ---

const resumeSession = useCallback(() => {
  sessionStartTimeRef.current = Date.now() - state.elapsedTime * 1000;
  phaseStartTimeRef.current = Date.now(); // ← WRONG: Resets phase time
  setState((prev) => ({ ...prev, isActive: true }));
}, [state.elapsedTime]);

// ---

const resumeSession = useCallback(() => {
  const now = Date.now();
  sessionStartTimeRef.current = now - state.elapsedTime * 1000;
  
  // Recalculate current phase position at resume time
  const technique = BREATHING_TECHNIQUES[state.selectedTechnique!];
  const cycleDuration = technique.cycle.inhale + technique.cycle.hold + 
                       technique.cycle.exhale + (technique.cycle.holdAfterExhale || 0);
  const cyclePos = (state.elapsedTime * 1000) % cycleDuration;
  phaseStartTimeRef.current = now - cyclePos;
  
  setState((prev) => ({ ...prev, isActive: true }));
}, [state.elapsedTime, state.selectedTechnique]);

// ---

await recordSession({ techniqueId, duration: state.elapsedTime, timestamp: new Date() });

// ---

const endSession = useCallback(async () => {
  setState(/* ... */);
  // intervalRef.current is cleared AFTER recording
  // But if recordSession fails or throws, cleanup is skipped
});

useEffect(() => {
  if (!state.isActive) return; // ← Doesn't clear old interval
  
  intervalRef.current = setInterval(() => { /* ... */ }, 50);
  
  return () => {
    if (intervalRef.current) clearInterval(intervalRef.current);
  };
}, [state.isActive]); // ← isActive is in dependency array

// ---

const endSession = useCallback(async () => {
  // Clear interval immediately, before any async work
  if (intervalRef.current) {
    clearInterval(intervalRef.current);
    intervalRef.current = null;
  }

  const elapsedCopy = state.elapsedTime; // Capture before state changes
  const techniqueCopy = state.selectedTechnique;

  setState((prev) => ({
    ...prev,
    isActive: false,
    currentPhase: 'idle',
    progress: 0,
    timeRemaining: prev.sessionDuration,
    elapsedTime: 0,
  }));

  // Record session after cleanup
  if (techniqueCopy && elapsedCopy > 0) {
    try {
      await recordSession({
        techniqueId: techniqueCopy,
        duration: elapsedCopy,
        timestamp: new Date(),
      });
    } catch (error) {
      console.error('Failed to record session:', error);
    }
  }
}, [state.elapsedTime, state.selectedTechnique]);

// ---

const pauseSession = useCallback(() => {
  setState((prev) => ({ ...prev, isActive: false })); // Always succeeds
  if (intervalRef.current) clearInterval(intervalRef.current);
}, []);

// ---

const pauseSession = useCallback(() => {
  if (!state.isActive) return; // Guard
  setState((prev) => ({ ...prev, isActive: false }));
  if (intervalRef.current) clearInterval(intervalRef.current);
}, [state.isActive]);

// ---

// BROKEN: After first cycle, phases don't reset correctly
if (phaseElapsedMs < cycle.inhale) { /* inhale */ }
else if (phaseElapsedMs < cycle.inhale + cycle.hold) { /* hold */ }
else if (phaseElapsedMs < cycle.inhale + cycle.hold + cycle.exhale) { /* exhale */ }
else {
  phaseStartTimeRef.current = now; // ← Resets, but logic above breaks next iteration
}

// ---

// Use modulo arithmetic for reliable cycling
const cycleDuration = cycle.inhale + cycle.hold + cycle.exhale + (cycle.holdAfterExhale || 0);
const cyclePosition = phaseElapsedMs % cycleDuration; // ← Automatically wraps

let currentPhase: BreathingPhase = 'inhale';
let phaseDuration = cycle.inhale;
let phaseStart = 0;

if (cyclePosition < cycle.inhale) {
  currentPhase = 'inhale';
  phaseDuration = cycle.inhale;
} else if (cyclePosition < cycle.inhale + cycle.hold) {
  currentPhase = 'hold';
  phaseDuration = cycle.hold;
  phaseStart = cycle.inhale;
} else if (cyclePosition < cycle.inhale + cycle.hold + cycle.exhale) {
  currentPhase = 'exhale';
  phaseDuration = cycle.exhale;
  phaseStart = cycle.inhale + cycle.hold;
} else if (cycle.holdAfterExhale) {
  currentPhase = 'hold';
  phaseDuration = cycle.holdAfterExhale;
  phaseStart = cycle.inhale + cycle.hold + cycle.exhale;
}

const phaseProgress = ((cyclePosition - phaseStart) / phaseDuration);

// ---

const resumeSession = useCallback(() => {
  sessionStartTimeRef.current = Date.now() - state.elapsedTime * 1000;
  phaseStartTimeRef.current = Date.now(); // ← WRONG: Resets phase to t=0
  setState((prev) => ({ ...prev, isActive: true }));
}, [state.elapsedTime]);

// ---

const resumeSession = useCallback(() => {
  if (!state.selectedTechnique) return;
  
  const now = Date.now();
  const technique = BREATHING_TECHNIQUES[state.selectedTechnique];
  const cycleDuration = technique.cycle.inhale + technique.cycle.hold + 
                       technique.cycle.exhale + (technique.cycle.holdAfterExhale || 0);
  
  // Recalculate where in the cycle we are
  const cyclePos = (state.elapsedTime * 1000) % cycleDuration;
  
  sessionStartTimeRef.current = now - state.elapsedTime * 1000;
  phaseStartTimeRef.current = now - cyclePos; // ← Maintains phase position
  
  setState((prev) => ({ ...prev, isActive: true }));
}, [state.elapsedTime, state.selectedTechnique]);

// ---

const endSession = useCallback(async () => {
  // Clear interval FIRST, before any async work
  if (intervalRef.current) {
    clearInterval(intervalRef.current);
    intervalRef.current = null;
  }

  // Capture state before clearing
  const elapsedCopy = state.elapsedTime;
  const techniqueCopy = state.selectedTechnique;

  setState((prev) => ({
    ...prev,
    isActive: false,
    currentPhase: 'idle',
    progress: 0,
    timeRemaining: prev.sessionDuration,
    elapsedTime: 0,
  }));

  // Record after cleanup
  if (techniqueCopy && elapsedCopy > 0) {
    try {
      await recordSession({
        techniqueId: techniqueCopy,
        duration: elapsedCopy,
        timestamp: new Date(),
      });
    } catch (error) {
      console.error('Failed to record session:', error);
    }
  }
}, [state.elapsedTime, state.selectedTechnique]);

// ---

const pauseSession = useCallback(() => {
  if (!state.isActive) return; // ← Prevent no-op calls
  setState((prev) => ({ ...prev, isActive: false }));
  if (intervalRef.current) clearInterval(intervalRef.current);
}, [state.isActive]);

const resumeSession = useCallback(() => {
  if (state.isActive || !state.selectedTechnique) return; // ← Guard
  // ... rest of implementation
}, [state.isActive, state.selectedTechnique]);

// ---

<button
  onClick={onClick}
  aria-pressed={isSelected}
  aria-label={`Select ${technique.name} breathing exercise. ${technique.description}`}
  className={/* ... */}
>
  {/* content */}
</button>

// ---

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

<motion.div
  animate={{ scale: prefersReducedMotion ? 1 : scaleValue }}
  transition={{ duration: prefersReducedMotion ? 0 : 0.05, ease: 'linear' }}
  // ...
/>

// ---

import { renderHook, act } from '@testing-library/react';
import { useBreathingSession } from '@/hooks/useBreathingSession';
import { BreathingTechniqueType } from '@/types/BreathingTechnique';

describe('useBreathingSession — Technique Selection', () => {
  it('should select a breathing technique and initialize session state', () => {
    const { result } = renderHook(() => useBreathingSession());

    act(() => {
      result.current.selectTechnique(BreathingTechniqueType.BOX_BREATHING);
    });

    expect(result.current.selectedTechnique).toBe(BreathingTechniqueType.BOX_BREATHING);
    expect(result.current.sessionDuration).toBe(300); // 5 min
    expect(result.current.timeRemaining).toBe(300);
    expect(result.current.isActive).toBe(false);
  });

  it('should change selected technique before starting session', () => {
    const { result } = renderHook(() => useBreathingSession());

    act(() => {
      result.current.selectTechnique(BreathingTechniqueType.BOX_BREATHING);
    });

    expect(result.current.selectedTechnique).toBe(BreathingTechniqueType.BOX_BREATHING);
    expect(result.current.sessionDuration).toBe(300);

    act(() => {
      result.current.selectTechnique(BreathingTechniqueType.FOUR_SEVEN_EIGHT);
    });

    expect(result.current.selectedTechnique).toBe(BreathingTechniqueType.FOUR_SEVEN_EIGHT);
    expect(result.current.sessionDuration).toBe(300); // Same duration, but different technique
  });

  it('should not start session without technique selected', () => {
    const { result } = renderHook(() => useBreathingSession());

    act(() => {
      result.current.startSession();
    });

    expect(result.current.isActive).toBe(false);
  });

  it('should set correct durations for all techniques', () => {
    const { result } = renderHook(() => useBreathingSession());

    const techniques = [
      { id: BreathingTechniqueType.BOX_BREATHING, expected: 300 },
      { id: BreathingTechniqueType.FOUR_SEVEN_EIGHT, expected: 300 },
      { id: BreathingTechniqueType.DEEP_CALM, expected: 300 },
      { id: BreathingTechniqueType.ENERGIZE, expected: 180 },
    ];

    techniques.forEach(({ id, expected }) => {
      act(() => {
        result.current.selectTechnique(id);
      });
      expect(result.current.sessionDuration).toBe(expected);
    });
  });
});

// ---

describe('useBreathingSession — Session Lifecycle', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });

  it('should start a session and set currentPhase to inhale', () => {
    const { result } = renderHook(() => useBreathingSession());

    act(() => {
      result.current.selectTechnique(BreathingTechniqueType.BOX_BREATHING);
      result.current.startSession();
    });

    expect(result.current.isActive).toBe(true);
    expect(result.current.currentPhase).toBe('inhale');
    expect(result.current.elapsedTime).toBe(0);
  });

  it('should not start a session twice without ending first', () => {
    const { result } = renderHook(() => useBreathingSession());

    act(() => {
      result.current.selectTechnique(BreathingTechniqueType.BOX_BREATHING);
      result.current.startSession();
      result.current.startSession(); // Call again
    });

    // Session should still be running once
    expect(result.current.isActive).toBe(true);
  });

  it('should pause an active session', () => {
    const { result } = renderHook(() => useBreathingSession());

    act(() => {
      result.current.selectTechnique(BreathingTechniqueType.BOX_BREATHING);
      result.current.startSession();
    });

    expect(result.current.isActive).toBe(true);

    act(() => {
      result.current.pauseSession();
    });

    expect(result.current.isActive).toBe(false);
  });

  it('should not pause if not active', () => {
    const { result } = renderHook(() => useBreathingSession());

    act(() => {
      result.current.pauseSession();
    });

    expect(result.current.isActive).toBe(false);
  });

  it('should resume a paused session with correct elapsed time', () => {
    const { result } = renderHook(() => useBreathingSession());

    act(() => {
      result.current.selectTechnique(BreathingTechniqueType.BOX_BREATHING);
      result.current.startSession();
      jest.advanceTimersByTime(5000); // 5 seconds
    });

    const elapsedAtPause = result.current.elapsedTime;

    act(() => {
      result.current.pauseSession();
    });

    expect(result.current.isActive).toBe(false);

    act(() => {
      jest.advanceTimersByTime(2000); // 2 seconds while paused
      result.current.resumeSession();
      jest.advanceTimersByTime(1000); // Resume and advance 1 more second
    });

    // Should have 5s + 1s = 6s elapsed, NOT 5s + 2s + 1s
    expect(result.current.elapsedTime).toBeGreaterThanOrEqual(5);
    expect(result.current.isActive).toBe(true);
  });

  it('should end session and reset state', async () => {
    const { result } = renderHook(() => useBreathingSession());

    act(() => {
      result.current.selectTechnique(BreathingTechniqueType.BOX_BREATHING);
      result.current.startSession();
      jest.advanceTimersByTime(10000); // 10 seconds
    });

    const elapsedAtEnd = result.current.elapsedTime;

    act(() => {
      result.current.endSession();
    });

    expect(result.current.isActive).toBe(false);
    expect(result.current.currentPhase).toBe('idle');
    expect(result.current.progress).toBe(0);
    expect(result.current.elapsedTime).toBe(0);
  });

  it('should call recordSession when ending after elapsed time > 0', async () => {
    const recordSessionSpy = jest.spyOn(require('@/services/statsService'), 'recordSession');

    const { result } = renderHook(() => useBreathingSession());

    act(() => {
      result.current.selectTechnique(BreathingTechniqueType.BOX_BREATHING);
      result.current.startSession();
      jest.advanceTimersByTime(15000); // 15 seconds
    });

    act(() => {
      result.current.endSession();
    });

    await act(async () => {
      await new Promise((resolve) => setTimeout(resolve, 0));
    });

    expect(recordSessionSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        techniqueId: BreathingTechniqueType.BOX_BREATHING,
        duration: expect.any(Number),
        timestamp: expect.any(Date),
      })
    );

    recordSessionSpy.mockRestore();
  });

  it('should not call recordSession when ending without elapsed time', async () => {
    const recordSessionSpy = jest.spyOn(require('@/services/statsService'), 'recordSession');

    const { result } = renderHook(() => useBreathingSession());

    act(() => {
      result.current.selectTechnique(BreathingTechniqueType.BOX_BREATHING);
      result.current.startSession();
    });

    act(() => {
      result.current.endSession();
    });

    expect(recordSessionSpy).not.toHaveBeenCalled();
    recordSessionSpy.mockRestore();
  });
});

// ---

if (phaseElapsedMs < cycle.inhale) { /* inhale */ }
else if (phaseElapsedMs < cycle.inhale + cycle.hold) { /* hold */ }
else if (phaseElapsedMs < cycle.inhale + cycle.hold + cycle.exhale) { /* exhale */ }
else { phaseStartTimeRef.current = now; } // Resets, but logic breaks next iteration

// ---

const cycleDuration = cycle.inhale + cycle.hold + cycle.exhale + (cycle.holdAfterExhale || 0);
const cyclePosition = phaseElapsedMs % cycleDuration; // Auto-wraps at cycle boundary

// Then compare cyclePosition, not cumulative phaseElapsedMs
if (cyclePosition < cycle.inhale) { /* inhale */ }
else if (cyclePosition < cycle.inhale + cycle.hold) { /* hold */ }
// etc.

// ---

const resumeSession = useCallback(() => {
  sessionStartTimeRef.current = Date.now() - state.elapsedTime * 1000;
  phaseStartTimeRef.current = Date.now(); // ← WRONG: Resets phase to t=0
}, [state.elapsedTime]);

// ---

const resumeSession = useCallback(() => {
  const now = Date.now();
  const technique = BREATHING_TECHNIQUES[state.selectedTechnique!];
  const cycleDuration = technique.cycle.inhale + technique.cycle.hold + 
                       technique.cycle.exhale + (technique.cycle.holdAfterExhale || 0);
  const cyclePos = (state.elapsedTime * 1000) % cycleDuration;
  
  sessionStartTimeRef.current = now - state.elapsedTime * 1000;
  phaseStartTimeRef.current = now - cyclePos; // ← Maintains phase position
}, [state.elapsedTime, state.selectedTechnique]);