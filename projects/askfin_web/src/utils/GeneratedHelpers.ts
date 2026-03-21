// Exam types
export {
  ExamState,
  type CategoryBreakdown,
  type ExamSession,
  type ExamQuestion,
  type ExamOption,
  type ExamResult,
  type ExamHistoryEntry,
  type ExamRepository,
  type ExamStartConfig,
} from "./exam";

// Training mode types (reference)
export {
  type TrainingQuestion,
  type TrainingOption,
  type TrainingSession,
} from "./training-mode";

// ---
// ❌ Problem: Map<string, string> doesn't serialize to JSON
// answers: Map<string, string>;

// ---
// ❌ Redundant
// passed: boolean;
// score: number;

// ---
// ❌ Unclear intent
// explanation?: string;

// ---
// ❌ Problem 1: completeExam needs timeSpent—where does it come from?
// completeExam(sessionId: string): Promise<ExamResult>;

// ❌ Problem 2: No upsert for submitted answers
// submitAnswer(...): Promise<void>; // Silent fail if session not found

// ❌ Problem 3: No method to retrieve active session

// ---
// ❌ FAILS in localStorage/API
// answers: Map<string, string>;

// ---
// ❌ How do you calculate timeSpent?
// completeExam(sessionId: string): Promise<ExamResult>;

// ---
// Service layer would do:
// const session = await repo.getActiveSession(sessionId);
// const timeSpent = Date.now() - session.startTime;
// const result = await repo.completeExam(sessionId, timeSpent);

// ---
// ❌ Client doesn't know if answer was saved
// submitAnswer(sessionId: string, questionId: string, answerId: string): Promise<void>;

// ---
// const updated = await repo.submitAnswer(sessionId, q1, "a2");
// console.log(updated.answers); // Verify it saved

// ---
// ❌ Unclear when explanation is present
// explanation?: string;

// ---
// ❌ Redundant field
// passed: boolean;
// score: number;
// passingScore: number; // Not defined!