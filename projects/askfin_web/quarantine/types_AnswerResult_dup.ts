export type AnswerResult = 
  | { ok: true; session: TrainingSession }
  | { ok: false; error: string };

  session: TrainingSession,
  selectedAnswer: string,
  timeSpentMs: number
): AnswerResult {
  if (!session.isActive) {
    return { ok: false, error: 'Session ended' };
  }
  if (session.currentQuestionIndex >= session.questions.length) {
    return { ok: false, error: 'All questions answered' };
  }
  if (!selectedAnswer?.trim()) {
    return { ok: false, error: 'Answer required' };
  }
  if (timeSpentMs < 0) {
    return { ok: false, error: 'Invalid time value' };
  }

  const currentQuestion = session.questions[session.currentQuestionIndex];
  const isCorrect = selectedAnswer === currentQuestion.correctAnswer;

  return {
    ok: true,
    session: {
      ...session,
      answers: [
        ...session.answers,
        { questionId: currentQuestion.id, selectedAnswer, isCorrect, timeSpentMs },
      ],
      currentQuestionIndex: session.currentQuestionIndex + 1,
    },
  };
}