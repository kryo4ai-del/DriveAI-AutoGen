/**
 * Exam repository error types
 */
export class ExamRepositoryError extends Error {
  constructor(
    public code: "NOT_FOUND" | "INVALID_STATE" | "VALIDATION_FAILED",
    message: string
  ) {
    super(message);
    this.name = "ExamRepositoryError";
  }
}

export interface ExamRepository {
  /**
   * Start a new exam session
   * @throws ExamRepositoryError if config invalid
   */
  startExam(config: ExamStartConfig): Promise<ExamSession>;

  /**
   * Get active session
   * @throws ExamRepositoryError with code NOT_FOUND if session doesn't exist
   */
  getActiveSession(sessionId: string): Promise<ExamSession>;

  /**
   * Submit answer to active session
   * @throws ExamRepositoryError if session expired or answer invalid
   */
  submitAnswer(
    sessionId: string,
    questionId: string,
    answerId: string
  ): Promise<ExamSession>;

  /**
   * Complete exam and generate result
   * @throws ExamRepositoryError if session not found or already completed
   */
  completeExam(sessionId: string, timeSpent: number): Promise<ExamResult>;

  /**
   * Retrieve exam history
   */
  getExamHistory(limit?: number): Promise<ExamHistoryEntry[]>;

  /**
   * Get single exam result
   */
  getExamResult(resultId: string): Promise<ExamResult | null>;

  /**
   * Clear all exam history
   */
  clearHistory(): Promise<void>;
}