'use client';

import { ReadinessData, TREND_LABELS } from '@/types/readiness';

interface ReadinessCardProps {
  readiness: ReadinessData;
}

export function ReadinessCard({ readiness }: ReadinessCardProps) {
  const trendLabel = TREND_LABELS[readiness.trend];
  const achievedCount = readiness.milestones.filter(m => m.achieved).length;

  return (
    <div className="rounded-lg border border-gray-200 p-6">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-lg font-semibold">Readiness Score</h2>
        <span className="text-3xl font-bold">{readiness.overallScore}%</span>
      </div>

      <div className="text-sm text-gray-600 mb-4">
        {trendLabel} · {achievedCount}/{readiness.milestones.length} milestones
      </div>

      <div className="space-y-2">
        {readiness.milestones.map((milestone, idx) => (
          <div key={idx} className="flex items-center gap-2">
            <input
              type="checkbox"
              checked={milestone.achieved}
              disabled
              className="rounded"
            />
            <span className="text-sm">{milestone.name}</span>
            {milestone.achievedAt && (
              <span className="text-xs text-gray-500">
                {new Date(milestone.achievedAt).toLocaleDateString()}
              </span>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}