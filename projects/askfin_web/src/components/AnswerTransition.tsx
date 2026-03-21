'use client';

import { AnimatePresence, motion } from 'framer-motion';
import type { Answer } from '@/app/exam-simulation/types/exam';

interface AnswerTransitionProps {
  answers: Answer[];
  onSelect: (answerId: string) => void;
  selectedId?: string;
  isDisabled?: boolean;
  ariaLabelledBy?: string;
}

export function AnswerTransition({
  answers,
  onSelect,
  selectedId,
  isDisabled = false,
  ariaLabelledBy,
}: AnswerTransitionProps) {
  return (
    <div
      role="group"
      aria-labelledby={ariaLabelledBy}
      className="space-y-2 sm:space-y-3 max-w-2xl"
    >
      <AnimatePresence mode="wait">
        {answers.map((answer, index) => (
          <motion.button
            key={answer.id}
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            transition={{ delay: index * 0.05, duration: 0.2 }}
            onClick={() => onSelect(answer.id)}
            disabled={isDisabled}
            className={`
              w-full p-3 sm:p-4 rounded-lg border-2 text-left
              transition-all duration-200
              text-sm sm:text-base font-medium
              ${
                selectedId === answer.id
                  ? 'border-blue-500 bg-blue-50 dark:bg-blue-950 dark:border-blue-600'
                  : 'border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 hover:border-blue-300 dark:hover:border-blue-700'
              }
              focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2
              dark:focus:ring-offset-slate-950
              disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:border-gray-200
            `}
            aria-pressed={selectedId === answer.id}
            aria-label={`Answer: ${answer.text}`}
          >
            <span className="text-gray-900 dark:text-gray-100">{answer.text}</span>
          </motion.button>
        ))}
      </AnimatePresence>
    </div>
  );
}