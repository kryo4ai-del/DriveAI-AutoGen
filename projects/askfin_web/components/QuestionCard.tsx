'use client';

import { Question } from '@/types/question';
import AnswerButton from './AnswerButton';

interface QuestionCardProps {
  question: Question;
  isAnswered: boolean;
  selectedAnswerId: string | null;
  onAnswer: (answerId: string) => void;
}

export default function QuestionCard({
  question,
  isAnswered,
  selectedAnswerId,
  onAnswer,
}: QuestionCardProps) {
  return (
    <article className="bg-white rounded-xl shadow-md p-6 md:p-8">
      {/* Question section */}
      <section className="mb-8">
        <h2 className="text-2xl md:text-3xl font-bold text-gray-900 leading-tight">
          {question.text}
        </h2>

        {/* Optional question image */}
        {question.imageUrl && (
          <img
            src={question.imageUrl}
            alt="Question illustration"
            className="mt-6 rounded-lg max-h-64 w-full object-cover"
          />
        )}
      </section>

      {/* Answer options */}
      <section className="space-y-3" role="group" aria-label="Answer options">
        {question.answers.map((answer) => (
          <AnswerButton
            key={answer.id}
            answer={answer}
            isSelected={selectedAnswerId === answer.id}
            isAnswered={isAnswered}
            onSelect={() => onAnswer(answer.id)}
          />
        ))}
      </section>

      {/* Explanation (shown after answer) */}
      {isAnswered && question.explanation && (
        <section
          className="mt-8 p-4 bg-blue-50 border-l-4 border-blue-600 rounded"
          role="complementary"
          aria-label="Explanation"
        >
          <h3 className="text-sm font-semibold text-blue-900 mb-2">
            Why? 📖
          </h3>
          <p className="text-gray-700 text-base leading-relaxed">
            {question.explanation}
          </p>
        </section>
      )}
    </article>
  );
}