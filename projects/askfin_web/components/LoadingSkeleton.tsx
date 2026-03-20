// ✅ FIX: Announce loading state
export function LoadingSkeleton() {
  return (
    <div
      className="w-full max-w-2xl mx-auto space-y-4 sm:space-y-6 p-4 sm:p-6"
      role="status"
      aria-live="polite"
      aria-label="Loading exam content"
    >
      {/* Visually hidden text for screen readers */}
      <span className="sr-only">Loading exam. Please wait...</span>

      {/* Timer skeleton */}
      <div
        className="h-10 w-24 rounded-lg bg-gray-200 dark:bg-gray-700 animate-pulse"
        aria-hidden="true"
      />
      
      {/* Question skeleton */}
      <div className="space-y-3 pt-2" aria-hidden="true">
        <div className="h-8 w-4/5 rounded bg-gray-200 dark:bg-gray-700 animate-pulse" />
        <div className="h-6 w-full rounded bg-gray-200 dark:bg-gray-700 animate-pulse" />
      </div>

      {/* Answers skeleton */}
      <div className="space-y-2 sm:space-y-3 pt-6" aria-hidden="true">
        {[...Array(4)].map((_, i) => (
          <div
            key={i}
            className="h-14 sm:h-16 rounded-lg border-2 border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800 animate-pulse"
          />
        ))}
      </div>
    </div>
  );
}