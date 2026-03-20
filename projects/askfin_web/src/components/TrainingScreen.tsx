'use client';

import { useCallback, useEffect, useState } from 'react';
import { useTrainingSession } from '@/hooks/useTrainingSession';
import { useQuestionList } from '@/hooks/useQuestionList';
import QuestionCard from './QuestionCard';
import TrainingResult from './TrainingResult';
import { TRAINING_PASS_THRESHOLD } from '../types/Training';
import { TRAINING_PASS_THRESHOLD } from '../../Models/TRAINING_PASS_THRESHOLD';

interface TrainingScreenState {
  currentIndex: number;
  isAnswered: boolean;
  selectedAnswerId: string | null;
}

export default function TrainingScreen() {
  const { session, submitAnswer, endSession } = useTrainingSession();
  const { questions, isLoading, error } = useQuestionList();
  const [state, setState] = useState<TrainingScreenState>({
    currentIndex: 0,
    isAnswered: false,
    selectedAnswerId: null,
  });

  // ✅ FIX: Check session completion with proper dependencies
  useEffect(() => {
    if (!session || questions.length === 0) return;

    const isSessionComplete =
      state.currentIndex >= questions.length && state.isAnswered;

    if (isSessionComplete) {
      endSession();
    }
  }, [state.currentIndex, state.isAnswered, questions.length, session, endSession]);

  // ✅ FIX: Capture question ID before async operation to prevent stale closure
  const handleAnswer = useCallback(
    async (answerId: string) => {
      // Guard: prevent double submission
      if (state.isAnswered) return;

      // Guard: ensure question exists
      const currentQuestion = questions[state.currentIndex];
      if (!currentQuestion) {
        console.error('Question not found at index', state.currentIndex);
        return;
      }

      // Capture question ID immediately (prevents race condition)
      const questionId = currentQuestion.id;

      // Update UI optimistically
      setState((prev) => ({
        ...prev,
        isAnswered: true,
        selectedAnswerId: answerId,
      }));

      // Submit answer asynchronously
      try {
        await submitAnswer(questionId, answerId);
      } catch (error) {
        console.error('Failed to submit answer:', error);
        // Revert UI on error
        setState((prev) => ({
          ...prev,
          isAnswered: false,
          selectedAnswerId: null,
        }));
      }
    },
    [state.currentIndex, state.isAnswered, questions, submitAnswer]
  );

  const handleNext = useCallback(() => {
    setState((prev) => ({
      currentIndex: prev.currentIndex + 1,
      isAnswered: false,
      selectedAnswerId: null,
    }));
  }, []);

  // ✅ FIX: Keyboard navigation accessibility
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Enter' && state.isAnswered) {
        handleNext();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [state.isAnswered, handleNext]);

  // Loading state
  if (isLoading) {
    return <TrainingLoadingScreen />;
  }

  // Error state
  if (error) {
    return <TrainingErrorScreen error={error} />;
  }

  // Session completed
  if (session?.isComplete && session.results) {
    return <TrainingResult results={session.results} />;
  }

  // No questions available
  if (questions.length === 0) {
    return <TrainingEmptyScreen />;
  }

  // ✅ FIX: Guard against out-of-bounds index
  const currentQuestion = questions[state.currentIndex];
  if (!currentQuestion) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-red-50">
        <div className="text-center max-w-sm">
          <div className="text-red-600 text-5xl mb-4">⚠️</div>
          <h2 className="text-xl font-bold text-gray-900 mb-2">
            Question Not Found
          </h2>
          <p className="text-gray-600">An unexpected error occurred.</p>
          <button
            onClick={() => window.location.reload()}
            className="mt-4 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
          >
            Reload Training
          </button>
        </div>
      </div>
    );
  }

  const progressPercent =
    ((state.currentIndex + 1) / questions.length) * 100;
  const isLastQuestion = state.currentIndex === questions.length - 1;

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white">
      {/* Header with progress */}
      <header className="sticky top-0 z-10 bg-white border-b border-gray-200 shadow-sm">
        <div className="max-w-2xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between mb-3">
            <span className="text-sm font-semibold text-gray-600">
              Question {state.currentIndex + 1} of {questions.length}
            </span>
            <span className="text-sm font-semibold text-blue-600">
              {session?.correctCount ?? 0} correct
            </span>
          </div>

          {/* ✅ FIX: Add proper ARIA attributes for accessibility */}
          <div className="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
            <div
              className="bg-blue-600 h-full transition-all duration-500 ease-out"
              style={{ width: `${progressPercent}%` }}
              role="progressbar"
              aria-valuenow={Math.round(progressPercent)}
              aria-valuemin={0}
              aria-valuemax={100}
              aria-label={`Training progress: ${state.currentIndex + 1} of ${questions.length} questions completed`}
            ></div>
          </div>
        </div>
      </header>

      {/* Main content */}
      <main className="max-w-2xl mx-auto px-4 py-8">
        <QuestionCard
          question={currentQuestion}
          isAnswered={state.isAnswered}
          selectedAnswerId={state.selectedAnswerId}
          onAnswer={handleAnswer}
        />

        {/* ✅ FIX: Proper button logic - disabled until answered */}
        {state.isAnswered && (
          <div className="mt-8 flex gap-4">
            <button
              onClick={handleNext}
              disabled={false}
              aria-label={
                isLastQuestion
                  ? 'Complete training session'
                  : 'Move to next question'
              }
              className={`flex-1 py-3 px-4 rounded-lg font-semibold text-white transition-all duration-200 active:scale-95 ${
                isLastQuestion
                  ? 'bg-green-600 hover:bg-green-700'
                  : 'bg-blue-600 hover:bg-blue-700'
              }`}
            >
              {isLastQuestion ? '✓ Complete Training' : 'Next Question →'}
            </button>
          </div>
        )}
      </main>
    </div>
  );
}

// ✅ Extracted loading screen component
function TrainingLoadingScreen() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-b from-blue-50 to-white">
      <div className="text-center">
        <div
          className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"
          role="status"
          aria-label="Loading training session"
        ></div>
        <p className="text-gray-600 font-medium">Loading training session...</p>
      </div>
    </div>
  );
}

// ✅ Extracted error screen component
function TrainingErrorScreen({ error }: { error: string }) {
  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-b from-red-50 to-white">
      <div className="text-center max-w-sm">
        <div className="text-red-600 text-5xl mb-4">⚠️</div>
        <h2 className="text-xl font-bold text-gray-900 mb-2">Training Error</h2>
        <p className="text-gray-600 mb-6">{error}</p>
        <button
          onClick={() => window.location.reload()}
          className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
        >
          Retry
        </button>
      </div>
    </div>
  );
}

// ✅ Extracted empty state component
function TrainingEmptyScreen() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-b from-blue-50 to-white">
      <div className="text-center max-w-sm">
        <div className="text-blue-600 text-5xl mb-4">📚</div>
        <h2 className="text-xl font-bold text-gray-900 mb-2">
          No Questions Available
        </h2>
        <p className="text-gray-600">Check back soon for more training questions.</p>
      </div>
    </div>
  );
}