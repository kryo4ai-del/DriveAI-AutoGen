// app/dashboard/page.tsx
'use client';

import ReadinessScore from '@/components/ReadinessScore/ReadinessScore';
import { ReadinessScoreData, Milestone } from '@/types/readiness';

const mockData: ReadinessScoreData = {
  score: 78,
  trend: 'up',
  trendPercent: 5,
  previousScore: 73,
  milestonesUnlocked: [
    {
      id: 'milestone-1',
      label: 'Traffic Signs',
      threshold: 50,
      icon: '🚦',
      unlocked: true,
      unlockedAt: new Date().toISOString(),
    },
    {
      id: 'milestone-2',
      label: 'Road Rules',
      threshold: 75,
      icon: '📋',
      unlocked: true,
      unlockedAt: new Date().toISOString(),
    },
  ],
  lastUpdated: new Date().toISOString(),
};

export default function DashboardPage() {
  return (
    <div className="container mx-auto py-8">
      <ReadinessScore
        data={mockData}
        animated={true}
        onAnimationComplete={() => console.log('Animation done')}
      />
    </div>
  );
}