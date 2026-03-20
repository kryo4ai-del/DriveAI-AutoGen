export interface ExamQuestion {
  id: string;
  category: string;
  text: string;
  options: ExamOption[];
  correctAnswerId: string;
  explanation: string; // ✅ Always required
}