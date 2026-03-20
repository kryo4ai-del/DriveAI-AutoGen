// ❌ PROBLEM: Question, Answer, TrainingSessionResult types undefined
import { Question } from '@/types/question';
import { Answer } from '@/types/question';
import { TrainingSessionResult } from '@/types/training';

// ---

// ❌ PROBLEM: endSession missing from dependency array
useEffect(() => {
  if (!session) return;
  if (currentQuestionIndex >= questions.length && questions.length > 0) {
    endSession();  // ← function called but not in deps
  }
}, [currentQuestionIndex, questions.length, session]); // ❌ Missing endSession

// ---

}, [currentQuestionIndex, questions.length, session, endSession]);

// ---

const handleAnswer = async (answerId: string) => {
  if (isAnswered) return;
  setSelectedAnswerId(answerId);
  setIsAnswered(true);
  
  const currentQuestion = questions[currentQuestionIndex];
  await submitAnswer(currentQuestion.id, answerId); // ← What if currentQuestionIndex changes?
};

// ---

const handleAnswer = async (answerId: string) => {
  if (isAnswered) return;
  setSelectedAnswerId(answerId);
  setIsAnswered(true);

  const questionId = questions[currentQuestionIndex]?.id;
  if (!questionId) return;
  
  await submitAnswer(questionId, answerId);
};

// ---

const currentQuestion = questions[currentQuestionIndex];
// ❌ No guard - if questions is empty or index out of bounds, undefined

// ---

const currentQuestion = questions[currentQuestionIndex];
if (!currentQuestion) {
  return <div>Error: Question not found</div>;
}

// ---

<button
  onClick={handleNext}
  disabled={currentQuestionIndex >= questions.length - 1} // ❌ Wrong
>

// ---

disabled={false} // Always allow clicking to navigate or complete

// ---

// ❌ Progress bar, loading spinner, answer buttons lack accessibility
<div
  className="bg-blue-600 h-full transition-all duration-500 ease-out"
  style={{ width: `${progressPercent}%` }}
></div>

// ---

<div
  className="bg-blue-600 h-full transition-all duration-500 ease-out"
  style={{ width: `${progressPercent}%` }}
  role="progressbar"
  aria-valuenow={progressPercent}
  aria-valuemin={0}
  aria-valuemax={100}
  aria-label={`Training progress: ${progressPercent}%`}
></div>

// ---

<button
  onClick={onSelect}
  disabled={isAnswered}  // ← disabled but still renders onClick handler
  className={buttonClasses}
>

// ---

<button
  onClick={isAnswered ? undefined : onSelect}
  disabled={isAnswered}
  className={buttonClasses}
>

// ---

<Link
  href="/
  // ❌ HREF IS INCOMPLETE - SYNTAX ERROR

// ---

<Link
  href="/training"
  className="..."
>
  Try Again
</Link>

// ---

const passThreshold = 70; // ❌ Magic number - where does this come from?
results.weaknessAreas.slice(0, 3) // ❌ Why 3?

// ---

const PASS_THRESHOLD = 70;
const MAX_DISPLAYED_WEAKNESSES = 3;

// ---

const handleAnswer = async (answerId: string) => {
  // ...
  await submitAnswer(currentQuestion.id, answerId);
  // ❌ No try/catch - what if API fails?
};

// ---

try {
  await submitAnswer(questionId, answerId);
} catch (error) {
  setIsAnswered(false);
  setSelectedAnswerId(null);
  console.error('Failed to submit answer:', error);
  // Show error toast/notification
}

// ---

<span className="text-sm font-semibold text-blue-600">
  {session?.correctCount || 0} correct
</span>

// ---

useEffect(() => {
  const handleKeyPress = (e: KeyboardEvent) => {
    if (e.key === 'Enter' && isAnswered) {
      handleNext();
    }
  };
  window.addEventListener('keydown', handleKeyPress);
  return () => window.removeEventListener('keydown', handleKeyPress);
}, [isAnswered]);

// ---

// ❌ CURRENT (INCOMPLETE)
<Link
  href="/"  // ← HREF INCOMPLETE, CUT OFF

// ---

<Link
  href="/training"
  className="w-full py-3 px-4 rounded-lg bg-blue-600 text-white font-semibold hover:bg-blue-700 transition-colors"
>
  Try Another Session
</Link>
<Link
  href="/dashboard"
  className="w-full py-3 px-4 rounded-lg bg-gray-200 text-gray-900 font-semibold hover:bg-gray-300 transition-colors mt-3"
>
  Back to Dashboard
</Link>

// ---

// ❌ CURRENT
import { Question } from '@/types/question';
import { Answer } from '@/types/question';
import { TrainingSessionResult } from '@/types/training';
// These files don't exist → import errors

// ---

const handleAnswer = async (answerId: string) => {
  if (isAnswered) return;
  setSelectedAnswerId(answerId);
  setIsAnswered(true);

  const currentQuestion = questions[currentQuestionIndex];  // ⚠️ Captured at call time
  await submitAnswer(currentQuestion.id, answerId);        // But what if index changed?
};

// ---

const handleAnswer = async (answerId: string) => {
  if (isAnswered) return;

  // Capture question ID immediately, not async reference
  const questionId = questions[currentQuestionIndex]?.id;
  if (!questionId) {
    console.error('Question not found');
    return;
  }

  setSelectedAnswerId(answerId);
  setIsAnswered(true);

  try {
    await submitAnswer(questionId, answerId);
  } catch (error) {
    console.error('Failed to submit answer:', error);
    setIsAnswered(false);
    setSelectedAnswerId(null);
  }
};

// ---

useEffect(() => {
  if (!session) return;
  if (currentQuestionIndex >= questions.length && questions.length > 0) {
    endSession();  // ⚠️ Function called but missing from deps
  }
}, [currentQuestionIndex, questions.length, session]); // ❌ Missing: endSession

// ---

useEffect(() => {
  if (!session) return;
  if (currentQuestionIndex >= questions.length && questions.length > 0) {
    endSession();
  }
}, [currentQuestionIndex, questions.length, session, endSession]);

// ---

const currentQuestion = questions[currentQuestionIndex];
// No null check — if out of bounds or empty, currentQuestion = undefined

return (
  <QuestionCard
    question={currentQuestion}  // ⚠️ Passing undefined
    // ...
  />
);

// ---

<h2 className="text-2xl md:text-3xl font-bold text-gray-900 leading-tight">
  {question.text}  // ❌ CRASH: Cannot read property 'text' of undefined
</h2>

// ---

const currentQuestion = questions[currentQuestionIndex];

// Guard clause
if (!currentQuestion) {
  return (
    <div className="min-h-screen flex items-center justify-center bg-red-50">
      <div className="text-center">
        <p className="text-red-600 font-semibold">Question not found</p>
      </div>
    </div>
  );
}

return (
  <main className="max-w-2xl mx-auto px-4 py-8">
    <QuestionCard {...} />
    {/* ... */}
  </main>
);

// ---

<button
  onClick={handleNext}
  disabled={currentQuestionIndex >= questions.length - 1}  // ❌ Logic backwards
>
  {isLastQuestion ? 'Complete Training' : 'Next Question'}
</button>

// ---

<button
  onClick={handleNext}
  disabled={!isAnswered}  // Disable until question answered
  className={`... ${!isAnswered ? 'opacity-50 cursor-not-allowed' : ''}`}
>
  {isLastQuestion ? 'Complete Training' : 'Next Question'}
</button>

// ---

const isCorrect = answer.isCorrect;  // ⚠️ What if isCorrect is undefined?

if (!isAnswered) {
  // ...
} else if (showResult) {
  if (isCorrect) {  // ❌ Could be falsy for wrong reasons

// ---

const isCorrect = answer.isCorrect ?? false;  // Default to false if missing

// Explicit check
if (showResult && typeof isCorrect === 'boolean') {

// ---

// ❌ No error handling for:
const { session, submitAnswer, endSession } = useTrainingSession();
const { questions, isLoading, error } = useQuestionList();
// What if hooks throw?

// ---

'use client';

import { Component, ReactNode } from 'react';

export class TrainingErrorBoundary extends Component<
  { children: ReactNode },
  { hasError: boolean }
> {
  constructor(props: { children: ReactNode }) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-red-50">
          <div className="text-center">
            <p className="text-red-600 font-semibold">Training session error</p>
            <button onClick={() => window.location.reload()}>Reload</button>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}

// ---

<TrainingErrorBoundary>
  <TrainingScreen />
</TrainingErrorBoundary>

// ---

// ❌ Progress bar lacks ARIA
<div className="bg-blue-600 h-full" style={{ width: `${progressPercent}%` }}></div>

// ❌ Loading spinner not labeled
<div className="animate-spin rounded-full h-12 w-12"></div>

// ❌ Buttons lack proper labels
<button onClick={handleNext}>{isLastQuestion ? 'Complete' : 'Next'}</button>

// ---

{/* Progress bar */}
<div
  className="bg-blue-600 h-full transition-all"
  role="progressbar"
  aria-valuenow={progressPercent}
  aria-valuemin={0}
  aria-valuemax={100}
  aria-label={`Training progress: ${progressPercent}% complete`}
></div>

{/* Loading */}
<div className="animate-spin h-12 w-12 border-b-2 border-blue-600" aria-label="Loading training session"></div>

{/* Button */}
<button
  onClick={handleNext}
  aria-label={isLastQuestion ? 'Complete training session' : 'Move to next question'}
>

// ---

<div className="sticky top-0 z-10 bg-white border-b border-gray-200 shadow-sm">
  {/* No semantic meaning */}
</div>

<main className="max-w-2xl mx-auto px-4 py-8">
  {/* Main content */}
</main>

// ---

// ✅ CORRECT: Use semantic header element
<header className="sticky top-0 z-10 bg-white border-b border-gray-200 shadow-sm">
  <nav aria-label="Training progress">
    {/* Progress navigation */}
  </nav>
</header>

<main aria-label="Training session content">
  {/* Main content properly labeled */}
</main>

<footer className="text-center mt-8 py-4 border-t">
  {/* Page footer if applicable */}
</footer>

// ---

<div className="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
  <div
    className="bg-blue-600 h-full transition-all duration-500 ease-out"
    style={{ width: `${progressPercent}%` }}
  ></div>
</div>

// ---

<div className="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
  <div
    className="bg-blue-600 h-full transition-all duration-500 ease-out"
    style={{ width: `${progressPercent}%` }}
    role="progressbar"
    aria-valuenow={Math.round(progressPercent)}
    aria-valuemin={0}
    aria-valuemax={100}
    aria-label={`Training progress: Question ${currentIndex + 1} of ${questions.length}`}
  ></div>
</div>

// ---

<div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
<p className="text-gray-600 font-medium">Loading training session...</p>

// ---

<div
  className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"
  role="status"
  aria-live="polite"
  aria-label="Loading training session, please wait"
></div>
<p className="text-gray-600 font-medium" aria-live="assertive">
  Loading training session...
</p>

// ---

<button
  onClick={isAnswered ? undefined : onSelect}
  disabled={isAnswered}
  className={getButtonClasses()}
>
  <div className="flex items-center justify-between">
    <span className="text-base md:text-lg">{answer.text}</span>
    {showResult && <span>{isCorrect ? '✓' : '✗'}</span>}
  </div>
</button>

// ---

<button
  onClick={isAnswered ? undefined : onSelect}
  disabled={isAnswered}
  className={`${getButtonClasses()} focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2`}
  aria-pressed={isSelected && isAnswered}
  aria-checked={isSelected}
  role="radio"
  aria-label={`Option: ${answer.text}${
    showResult 
      ? (isCorrect ? ' - Correct answer' : ' - Incorrect answer') 
      : ''
  }`}
  aria-description={
    !isAnswered ? 'Click to select this answer' : undefined
  }
>
  <div className="flex items-center justify-between">
    <span className="text-base md:text-lg">{answer.text}</span>
    {showResult && (
      <span
        role="img"
        aria-hidden={false}
        aria-label={isCorrect ? 'Correct' : 'Incorrect'}
      >
        {isCorrect ? '✓' : '✗'}
      </span>
    )}
  </div>
</button>

// ---

<article className="bg-white rounded-xl shadow-md p-6 md:p-8">
  <section className="mb-8">
    <h2>{question.text}</h2>
  </section>

  <section className="space-y-3" role="group" aria-label="Answer options">
    {question.answers.map((answer) => (
      <AnswerButton {...} />
    ))}
  </section>
</article>

// ---

<form className="bg-white rounded-xl shadow-md p-6 md:p-8">
  <fieldset>
    <legend className="text-2xl md:text-3xl font-bold text-gray-900 leading-tight mb-8">
      {question.text}
    </legend>

    {question.imageUrl && (
      <img
        src={question.imageUrl}
        alt={`Visual aid for: ${question.text}`}
        className="mt-6 rounded-lg max-h-64 w-full object-cover"
      />
    )}

    {/* Answer options - now semantically grouped */}
    <div className="space-y-3 mt-6">
      {question.answers.map((answer) => (
        <AnswerButton key={answer.id} {...} />
      ))}
    </div>
  </fieldset>

  {/* Explanation section */}
  {isAnswered && question.explanation && (
    <aside className="mt-8 p-4 bg-blue-50 border-l-4 border-blue-600 rounded">
      <p className="text-sm font-semibold text-blue-900 mb-2">Why?</p>
      <p className="text-gray-700 text-base leading-relaxed">
        {question.explanation}
      </p>
    </aside>
  )}
</form>

// ---

<button
  onClick={handleNext}
  disabled={false}
  className={`flex-1 py-3 px-4 rounded-lg font-semibold text-white...`}
>
  {isLastQuestion ? '✓ Complete Training' : 'Next Question →'}
</button>

// ---

<button
  onClick={handleNext}
  disabled={!state.isAnswered}
  aria-label={
    isLastQuestion
      ? 'Complete training session and view results'
      : `Move to question ${currentIndex + 2} of ${questions.length}`
  }
  aria-disabled={!state.isAnswered}
  className={`flex-1 py-3 px-4 rounded-lg font-semibold text-white focus:outline-none focus:ring-2 focus:ring-green-600 focus:ring-offset-2...`}
  role="button"
>
  {isLastQuestion ? '✓ Complete Training' : 'Next Question →'}
</button>

// ---

// Disabled incorrect answer
return `${baseClasses} border-gray-300 bg-gray-50 text-gray-400 cursor-default opacity-50`;

// ---

// Disabled incorrect answer - higher contrast
return `${baseClasses} border-gray-300 bg-gray-100 text-gray-600 cursor-default opacity-70`;
// ✅ Contrast: ~5.1:1 (passes AA)

// Alternative: Keep opacity but darken text
return `${baseClasses} border-gray-300 bg-gray-50 text-gray-700 cursor-default opacity-60`;
// ✅ Contrast: ~4.8:1

// ---

<Link href="/training">
  Try Again
</Link>
<Link href="/dashboard">
  Back to Dashboard
</Link>

// ---

{/* Add skip link at top of result page */}
<a
  href="#result-actions"
  className="sr-only focus:not-sr-only focus:absolute focus:top-2 focus:left-2 focus:z-50 focus:px-4 focus:py-2 focus:bg-blue-600 focus:text-white focus:rounded"
>
  Skip to action buttons
</a>

{/* Later in component */}
<div id="result-actions" className="flex flex-col gap-3 mt-8">
  <Link
    href="/training"
    className="py-3 px-4 rounded-lg bg-blue-600 text-white font-semibold hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-600 focus:ring-offset-2 transition-all"
    aria-label="Try another training session"
  >
    Try Another Session
  </Link>
  <Link
    href="/dashboard"
    className="py-3 px-4 rounded-lg bg-gray-200 text-gray-900 font-semibold hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-400 focus:ring-offset-2 transition-all"
    aria-label="Return to dashboard"
  >
    Back to Dashboard
  </Link>
</div>