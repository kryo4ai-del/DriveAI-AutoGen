'use client';

interface EmptyStateProps {
  title?: string;
  description?: string;
  actionLabel?: string;
  onAction?: () => void;
}

export function EmptyState({
  title = 'Keine Fähigkeiten verfügbar',
  description = 'Starten Sie einen Kurs, um Ihre Fortschritte zu verfolgen.',
  actionLabel = 'Zum Dashboard',
  onAction,
}: EmptyStateProps) {
  return (
    <div
      className="col-span-full flex flex-col items-center justify-center py-12 px-4"
      role="status"
      aria-label="Leerer SkillMap-Status"
    >
      <div className="text-6xl mb-4" aria-hidden="true">
        📊
      </div>
      <h2 className="text-xl font-semibold text-gray-900 mb-2">{title}</h2>
      <p className="text-gray-600 text-center max-w-sm mb-6">{description}</p>
      {onAction && (
        <button
          onClick={onAction}
          className="px-6 py-2 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 active:bg-blue-800 transition-colors duration-150 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
        >
          {actionLabel}
        </button>
      )}
    </div>
  );
}