// ❌ CURRENT
export function QuestionCard({ question, number, total, onAnswer, selectedAnswerId, onTimeExpire }: QuestionCardProps) {
  const timer = useExamTimer(300, onTimeExpire || (() => {}));
  // ⚠️ New function created on every render → useExamTimer re-runs
  // Timer resets to 300 seconds repeatedly