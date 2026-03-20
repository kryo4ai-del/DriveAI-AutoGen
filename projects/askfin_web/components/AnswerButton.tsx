'use client';

import { Answer } from '@/types/question';

interface AnswerButtonProps {
  answer: Answer;
  isSelected: boolean;
  isAnswered: boolean;
  onSelect: () => void;
}

export default function AnswerButton({
  answer,
  isSelected,
  isAnswered,
  onSelect,
}: AnswerButtonProps) {
  const isCorrect = answer.isCorrect;
  const showResult = isAnswered && isSelected;

  let buttonClasses =
    'w-full p-4 text-left rounded-lg border-2 font-semibold transition-all duration-200 ';

  if (!isAnswered) {
    // Before answer
    buttonClasses +=
      'border-gray-300 bg-white text-gray-900 hover:border-blue-500 hover:bg-blue-50 active:scale-95 cursor-pointer';
  } else if (showResult) {
    // Selected answer (show feedback)
    if (isCorrect) {
      buttonClasses +=
        'border-green-500 bg-green-50 text-green-900 cursor-default';
    } else {
      buttonClasses +=
        'border-red-500 bg-red-50 text-red-900 cursor-default';
    }
  } else if (isCorrect && isAnswered) {
    // Show correct answer if not selected
    buttonClasses +=
      'border-green-300 bg-green-50 text-gray-900 cursor-default opacity-75';
  } else {
    // Disabled incorrect answer
    buttonClasses +=
      'border-gray-300 bg-gray-50 text-gray-400 cursor-default opacity-50';
  }

  return (
    <button
      onClick={onSelect}
      disabled={isAnswered}
      className={buttonClasses}
    >
      <div className="flex items-center justify-between">
        <span className="text-base md:text-lg">{answer.text}</span>

        {/* Feedback icon */}
        {showResult && (
          <span className="ml-3 text-xl">
            {isCorrect ? '✓' : '✗'}
          </span>
        )}
        {!showResult && isCorrect && isAnswered && (
          <span className="ml-3 text-xl text-green-600">✓</span>
        )}
      </div>
    </button>
  );
}