'use client';

import { useState, useCallback } from 'react';
import type { ExamState, Question } from '@/app/exam-simulation/types/exam';

export function useExamState(questions: Question[]) {
  const [state, setState] = useState<ExamState>({
    currentQuestionIndex: 0,
    answered: {},
    isComplete: false,
    score: 0,
  });

  const answerQuestion = useCallback(
    (answerId: string) => {
      setState((prev) => {
        const currentQuestion = questions[prev.currentQuestionIndex];
        const isCorrect = answerId === currentQuestion.correctAnswerId;

        return {
          ...prev,
          answered: { ...prev.answered, [currentQuestion.id]: answerId },
          score: prev.score + (isCorrect ? 1 : 0),
        };
      });
    },
    [questions]
  );

  const nextQuestion = useCallback(() => {
    setState((prev) => {
      const nextIndex = prev.currentQuestionIndex + 1;
      if (nextIndex >= questions.length) {
        return { ...prev, isComplete: true };
      }
      return { ...prev, currentQuestionIndex: nextIndex };
    });
  }, [questions.length]);

  const resetExam = useCallback(() => {
    setState({
      currentQuestionIndex: 0,
      answered: {},
      isComplete: false,
      score: 0,
    });
  }, []);

  return { state, answerQuestion, nextQuestion, resetExam };
}