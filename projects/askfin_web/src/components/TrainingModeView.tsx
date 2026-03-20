// components/TrainingMode/TrainingModeView.tsx
'use client';

import React from 'react';

interface Props {
  currentQuestion: string;
  options: string[];
  questionNumber: number;
  totalQuestions: number;
  onSelectOption: (option: string) => void;
  isLoading: boolean;
}

export const TrainingModeView: React.FC<Props> = ({
  currentQuestion,
  options,
  questionNumber,
  totalQuestions,
  onSelectOption,
  isLoading,
}) => {
  return (
    <main
      className="max-w-2xl mx-auto p-4 sm:p-6 lg:p-8"
      role="main"
      aria-label="Training mode quiz"
    >
      {/* Progress indicator */}
      <div className="mb-8">
        <div
          className="flex justify-between text-sm font-medium mb-2"
          aria-live="polite"
          aria-label={`Question ${questionNumber} of ${totalQuestions}`}
        >
          <span>Question {questionNumber}</span>
          <span>{totalQuestions} Total</span>
        </div>
        <div
          className="w-full bg-gray-200 rounded-full h-2"
          role="progressbar"
          aria-valuenow={questionNumber}
          aria-valuemin={1}
          aria-valuemax={totalQuestions}
        >
          <div
            className="bg-blue-600 h-2 rounded-full transition-all duration-300"
            style={{ width: `${(questionNumber / totalQuestions) * 100}%` }}
          />
        </div>
      </div>

      {/* Question */}
      <section className="mb-8">
        <h1
          className="text-xl sm:text-2xl font-bold text-gray-900 mb-6"
          id="question-text"
        >
          {currentQuestion}
        </h1>

        {/* Options */}
        <fieldset className="space-y-3">
          <legend className="sr-only">Select your answer</legend>
          {options.map((option, index) => (
            <label
              key={index}
              className="flex items-center p-4 border-2 border-gray-300 rounded-lg cursor-pointer hover:border-blue-500 transition disabled:opacity-50"
              htmlFor={`option-${index}`}
            >
              <input
                id={`option-${index}`}
                type="radio"
                name="training-option"
                value={option}
                onChange={() => onSelectOption(option)}
                disabled={isLoading}
                className="w-4 h-4 text-blue-600"
                aria-describedby="question-text"
              />
              <span className="ml-3 text-gray-900">{option}</span>
            </label>
          ))}
        </fieldset>
      </section>
    </main>
  );
};