// types/exam.ts
export interface ExamSession {
  id: string;
  startTime: number;
  duration: number;
  questions: ExamQuestion[];
  answers: Record<string, string>; // ✅ JSON-serializable
  isCompleted: boolean;
  state: ExamState;
}