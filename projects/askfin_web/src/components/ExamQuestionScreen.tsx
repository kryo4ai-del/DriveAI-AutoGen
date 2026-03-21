// components/ExamSimulation/ExamQuestionScreen.tsx
'use client';

import React, { useState, useEffect } from 'react';
import { Question } from './types';

interface ExamQuestionScreenProps {
  question: Question;
  questionNumber: number;
  totalQuestions: number;
  selectedAnswerId?: string;
  onAnswerSelect: (answerId: string) => void;
  onNext: () => void;
  onPrevious: () => void;
  onFinish: () => void;
  canGoBack: boolean;
  timeRemaining: number;
}

export function ExamQuestionScreen({
  question,
  questionNumber,
  totalQuestions,
  selectedAnswerId,
  onAnswerSelect,
  onNext,
  onPrevious,
  onFinish,
  canGoBack,
  timeRemaining,
}: ExamQuestionScreenProps) {
  const [isAnswered, setIsAnswered] = useState(!!selectedAnswerId);

  useEffect(() => {
    setIsAnswered(!!selectedAnswerId);
  }, [selectedAnswerId, questionNumber]);

  const minutes = Math.floor(timeRemaining / 60);
  const seconds = timeRemaining % 60;
  const isTimeRunningOut = timeRemaining < 300; // 5 minutes

  const isLastQuestion = questionNumber === totalQuestions;

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-6">
      <div className="max-w-3xl mx-auto">
        {/* Header */}
        <div className="flex justify-between items-center mb-8">
          <div className="text-lg font-semibold text-gray-800">
            Question {questionNumber} of {totalQuestions}
          </div>
          <div
            className={`text-lg font-bold ${
              isTimeRunningOut ? 'text-red-600' : 'text-indigo-600'
            }`}
          >
            ⏱️ {minutes}:{seconds.toString().padStart(2, '0')}
          </div>
        </div>

        {/* Progress Bar */}
        <div className="mb-8 bg-white rounded-lg shadow p-4">
          <div className="flex justify-between mb-2">
            <span className="text-sm font-medium text-gray-700">Progress</span>
            <span className="text-sm font-medium text-gray-700">
              {Math.round((questionNumber / totalQuestions) * 100)}%
            </span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-3">
            <div
              className="bg-indigo-600 h-3 rounded-full transition-all duration-300"
              style={{
                width: `${(questionNumber / totalQuestions) * 100}%`,
              }}
            />
          </div>
        </div>

        {/* Question Card */}
        <div className="bg-white rounded-lg shadow-lg p-8 mb-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-8">
            {question.text}
          </h2>

          {/* Answer Options */}
          <div className="space-y-4">
            {question.answers.map((answer) => (
              <button
                key={answer.id}
                onClick={() => onAnswerSelect(answer.id)}
                className={`w-full text-left p-4 rounded-lg border-2 transition duration-200 ${
                  selectedAnswerId === answer.id
                    ? 'border-indigo-600 bg-indigo-50'
                    : 'border-gray-200 bg-white hover:border-indigo-300'
                }`}
              >
                <div className="flex items-center">
                  <div
                    className={`w-6 h-6 rounded-full border-2 mr-4 flex items-center justify-center ${
                      selectedAnswerId === answer.id
                        ? 'border-indigo-600 bg-indigo-600'
                        : 'border-gray-300'
                    }`}
                  >
                    {selectedAnswerId === answer.id && (
                      <div className="w-2 h-2 bg-white rounded-full" />
                    )}
                  </div>
                  <span className="text-gray-900 font-medium">{answer.text}</span>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Navigation */}
        <div className="flex gap-4">
          <button
            onClick={onPrevious}
            disabled={!canGoBack}
            className={`flex-1 py-3 px-6 rounded-lg font-bold transition duration-200 ${
              canGoBack
                ? 'bg-gray-600 hover:bg-gray-700 text-white'
                : 'bg-gray-300 text-gray-500 cursor-not-allowed'
            }`}
          >
            ← Previous
          </button>

          {isLastQuestion ? (
            <button
              onClick={onFinish}
              disabled={!isAnswered}
              className={`flex-1 py-3 px-6 rounded-lg font-bold transition duration-200 ${
                isAnswered
                  ? 'bg-green-600 hover:bg-green-700 text-white'
                  : 'bg-gray-300 text-gray-500 cursor-not-allowed'
              }`}
            >
              Finish Exam ✓
            </button>
          ) : (
            <button
              onClick={onNext}
              disabled={!isAnswered}
              className={`flex-1 py-3 px-6 rounded-lg font-bold transition duration-200 ${
                isAnswered
                  ? 'bg-indigo-600 hover:bg-indigo-700 text-white'
                  : 'bg-gray-300 text-gray-500 cursor-not-allowed'
              }`}
            >
              Next →
            </button>
          )}
        </div>
      </div>
    </div>
  );
}