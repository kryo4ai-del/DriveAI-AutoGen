export function ExerciseSelection({
  selectedTechnique,
  isActive,
  currentPhase,
  progress,
  timeRemaining,
  onSelectTechnique,
  onStartSession,
  onPauseSession, // ← Props continue but component body never appears