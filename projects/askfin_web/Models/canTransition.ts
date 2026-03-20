/**
 * Exam session state machine
 * 
 * Valid transitions:
 * NOT_STARTED → IN_PROGRESS (startExam)
 * IN_PROGRESS → COMPLETED (completeExam)
 * COMPLETED → REVIEWING (optional, user action)
 * REVIEWING → IN_PROGRESS (only if time remaining)
 */
export enum ExamState {
  NOT_STARTED = "NOT_STARTED",
  IN_PROGRESS = "IN_PROGRESS",
  COMPLETED = "COMPLETED",
  REVIEWING = "REVIEWING",
}

/**
 * Validate state transition
 */
export function canTransition(
  from: ExamState,
  to: ExamState
): boolean {
  const validTransitions: Record<ExamState, ExamState[]> = {
    [ExamState.NOT_STARTED]: [ExamState.IN_PROGRESS],
    [ExamState.IN_PROGRESS]: [ExamState.COMPLETED, ExamState.REVIEWING],
    [ExamState.COMPLETED]: [ExamState.REVIEWING],
    [ExamState.REVIEWING]: [ExamState.IN_PROGRESS, ExamState.COMPLETED],
  };
  return validTransitions[from]?.includes(to) ?? false;
}