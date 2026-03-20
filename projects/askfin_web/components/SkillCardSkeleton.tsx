'use client';

export function SkillCardSkeleton() {
  return (
    <div className="bg-white rounded-lg shadow-md p-4 animate-pulse">
      {/* Header skeleton */}
      <div className="flex items-start justify-between gap-3 mb-3">
        <div className="flex-1">
          <div className="h-5 bg-gray-300 rounded w-3/4 mb-2" />
          <div className="h-4 bg-gray-300 rounded w-1/2" />
        </div>
        <div className="h-6 bg-gray-300 rounded-full w-20" />
      </div>

      {/* Progress bar skeleton */}
      <div className="mb-3 h-2 bg-gray-300 rounded-full w-full" />

      {/* Stats skeleton */}
      <div className="flex justify-between">
        <div className="h-4 bg-gray-300 rounded w-12" />
        <div className="h-4 bg-gray-300 rounded w-24" />
      </div>
    </div>
  );
}