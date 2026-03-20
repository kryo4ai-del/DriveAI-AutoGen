export function recordAnswer(session: any, selectedAnswer: any, timeSpentMs) {
  if (!session.isActive || session.currentQuestionIndex >= session.questions.length) {
    return session;  // ❌ Returns unchanged session without error signal
  }
}