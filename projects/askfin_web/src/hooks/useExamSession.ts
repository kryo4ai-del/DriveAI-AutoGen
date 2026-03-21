// hooks/useExamSession.ts
'use client';

import { useState, useCallback, useEffect, useRef } from 'react';
import {
  ExamSession,
  Question,
  ExamAnswer,
  SessionStatus,
} from '@/types/exam';
import {
  initializeSession,
  submitAnswer,
  getSessionProgress,
} from '@/services/examService';

export interface SubmitAnswerResult {
  success: boolean;
  answer?: ExamAnswer;
  error?: string;
}

export function useExamSession(examId: string): UseExamSessionReturn {
  const [session, setSession] = useState<ExamSession | null>(null);
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [answers, setAnswers] = useState<Map<string, ExamAnswer>>(new Map());
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const sessionRef = useRef<ExamSession | null>(null);

  // Initialize exam session
  useEffect(() => {
    const initialize = async () => {
      try {
        setIsLoading(true);
        setError(null);
        const newSession = await initializeSession(examId);
        setSession(newSession);
        sessionRef.current = newSession;
      } catch (err) {
        const message =
          err instanceof Error ? err.message : 'Failed to initialize exam';
        setError(message);
      } finally {
        setIsLoading(false);
      }
    };

    initialize();
  }, [examId]);

  // Direct value lookup, no memoization needed
  const currentQuestion: Question | null =
    session?.questions?.[currentQuestionIndex] ?? null;

  const hasAnswered = useCallback(
    (questionId: string) => answers.has(questionId),
    [answers]
  );

  // Handle answer submission with explicit success/failure contract
  const handleSubmitAnswer = useCallback(
    async (
      questionId: string,
      selectedOption: string
    ): Promise<SubmitAnswerResult> => {
      if (!sessionRef.current) {
        const msg = 'Session not initialized';
        setError(msg);
        return { success: false, error: msg };
      }

      try {
        const answer = await submitAnswer(
          sessionRef.current.id,
          questionId,
          selectedOption
        );

        setAnswers((prev) => new Map(prev).set(questionId, answer));
        setError(null);
        return { success: true, answer };
      } catch (err) {
        const message =
          err instanceof Error ? err.message : 'Failed to submit answer';
        setError(message);
        return { success: false, error: message };
      }
    },
    []
  );

  const nextQuestion = useCallback(() => {
    setCurrentQuestionIndex((prev) => {
      const next = prev + 1;
      const max = session?.questions.length ?? 0;
      return next < max ? next : prev;
    });
  }, [session?.questions.length]);

  const previousQuestion = useCallback(() => {
    setCurrentQuestionIndex((prev) => (prev > 0 ? prev - 1 : 0));
  }, []);

  const jumpToQuestion = useCallback(
    (index: number) => {
      if (!session?.questions) return;
      if (index >= 0 && index < session.questions.length) {
        setCurrentQuestionIndex(index);
      }
    },
    [session]
  );

  const handleEndSession = useCallback(async () => {
    try {
      if (!sessionRef.current) {
        throw new Error('Session not initialized');
      }

      setSession((prev) =>
        prev
          ? {
              ...prev,
              status: 'completed' as SessionStatus,
              endedAt: new Date(),
            }
          : null
      );
      setError(null);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : 'Failed to end session';
      setError(message);
      throw err;
    }
  }, []);

  return {
    session,
    currentQuestion,
    currentQuestionIndex,
    totalQuestions: session?.questions.length ?? 0,
    isLoading,
    error,
    answers,
    hasAnswered,
    submitAnswer: handleSubmitAnswer,
    nextQuestion,
    previousQuestion,
    jumpToQuestion,
    endSession: handleEndSession,
  };
}