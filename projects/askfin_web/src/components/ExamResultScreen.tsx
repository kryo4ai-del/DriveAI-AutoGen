export function ExamResultScreen({
  result,
  onRetry,
  onExit,
}: ExamResultScreenProps) {
  const minutes = Math.floor(result.timeSpent / 1000 / 60);
  const seconds = Math.floor((result.timeSpent / 1000) % 60);

  // Identify weak categories
  const weakCategories = result.categoryBreakdown.filter(c => c.percentage < 70);
  const strongCategories = result.categoryBreakdown.filter(c => c.percentage >= 70);

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-6">
      <div className="max-w-2xl mx-auto">
        {/* Score Display */}
        <div className={`rounded-lg shadow-lg p-8 text-center mb-8 ${
          result.isPassed ? 'bg-green-50' : 'bg-red-50'
        }`}>
          <div className="text-6xl font-bold mb-4">
            {result.isPassed ? '✅' : '❌'}
          </div>
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            {result.isPassed ? 'Exam Passed!' : 'Exam Not Passed'}
          </h1>
          <div className="text-5xl font-bold text-indigo-600 mb-4">
            {result.score}%
          </div>
          <p className="text-gray-600 mb-2">
            {result.score >= 80 && '🎉 Excellent score!'}
            {result.score >= 70 && result.score < 80 && '👍 Good job!'}
            {result.score < 70 && '📚 Review and try again'}
          </p>
          <p className="text-sm text-gray-500">
            Answered {result.totalQuestions} questions in {minutes}m {seconds}s
          </p>
        </div>

        {/* Category Breakdown */}
        <div className="bg-white rounded-lg shadow-lg p-8 mb-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">
            Performance by Category
          </h2>
          <CategoryBreakdownChart categories={result.categoryBreakdown} />
        </div>

        {/* Gap Analysis */}
        {weakCategories.length > 0 && (
          <div className="bg-yellow-50 border-2 border-yellow-300 rounded-lg p-6 mb-8">
            <h3 className="font-bold text-yellow-900 mb-4 text-lg">
              📌 Areas to Improve
            </h3>
            <ul className="space-y-3">
              {weakCategories.map(cat => (
                <li key={cat.category} className="text-yellow-900">
                  <span className="font-semibold">{cat.category}</span>
                  <span className="text-sm ml-2">
                    {cat.correct}/{cat.total} correct ({cat.percentage}%)
                  </span>
                  <p className="text-xs text-yellow-800 mt-1">
                    Review {cat.total - cat.correct} question{cat.total - cat.correct !== 1 ? 's' : ''} in this category
                  </p>
                </li>
              ))}
            </ul>
          </div>
        )}

        {/* Strengths */}
        {strongCategories.length > 0 && (
          <div className="bg-green-50 border-2 border-green-300 rounded-lg p-6 mb-8">
            <h3 className="font-bold text-green-900 mb-4 text-lg">
              ✅ Strong Areas
            </h3>
            <ul className="space-y-2">
              {strongCategories.map(cat => (
                <li key={cat.category} className="text-green-900 text-sm">
                  <span className="font-semibold">{cat.category}</span> ({cat.percentage}%)
                </li>
              ))}
            </ul>
          </div>
        )}

        {/* Actions */}
        <div className="flex gap-4">
          <button
            onClick={onRetry}
            className="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-3 px-6 rounded-lg transition duration-200"
            aria-label="Retry the exam"
          >
            🔄 Retry Exam
          </button>
          <button
            onClick={onExit}
            className="flex-1 bg-gray-600 hover:bg-gray-700 text-white font-bold py-3 px-6 rounded-lg transition duration-200"
            aria-label="Exit to home"
          >
            Exit
          </button>
        </div>
      </div>
    </div>
  );
}