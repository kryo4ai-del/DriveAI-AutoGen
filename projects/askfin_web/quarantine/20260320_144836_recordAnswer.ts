export function recordAnswer(session, selectedAnswer, timeSpentMs) {
  if (!session.isActive || session.currentQuestionIndex >= session.questions.length) {
    return session;  // ❌ Returns unchanged session without error signal
  }
}