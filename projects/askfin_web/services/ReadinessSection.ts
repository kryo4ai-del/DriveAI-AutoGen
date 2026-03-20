// app/dashboard/readiness-section.tsx

import { isReadinessData } from '@/types/readiness';

export async function ReadinessSection() {
  try {
    const response = await fetch('/api/user/readiness', {
      cache: 'no-store',
    });

    if (!response.ok) throw new Error('Failed to fetch readiness data');

    const data = await response.json();

    // Safe parsing with type guard
    if (!isReadinessData(data)) {
      throw new Error('Invalid readiness data structure from API');
    }

    return <ReadinessCard readiness={data} />;
  } catch (error) {
    return <ErrorFallback message="Could not load readiness data" />;
  }
}