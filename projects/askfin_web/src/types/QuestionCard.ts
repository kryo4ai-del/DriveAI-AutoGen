// ❌ CURRENT
export function QuestionCard({ question, number, total, onAnswer, selectedAnswerId, onTimeExpire }: QuestionCardProps) {
  const timer = useExamTimer(300, onTimeExpire || (() => {}));
  // ⚠️ New function created on every render → useExamTimer re-runs
  // Timer resets to 300 seconds repeatedly
}

interface QuestionCardProps {
  question: unknown;
  number: number;
  total: number;
  onAnswer: (answerId: string) => void;
  selectedAnswerId?: string;
  onTimeExpire?: () => void;
}

function useExamTimer(duration: number, onExpire: () => void) {
  return { duration, onExpire };
}