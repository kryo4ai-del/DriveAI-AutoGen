// app/dashboard/readiness-section.tsx

import { isReadinessData } from '@/types/readiness';
import { ReactNode } from 'react';

function ReadinessCard({ readiness }: { readiness: unknown }): ReactNode {
  return <div>{/* Readiness card content */}</div>;
}

function ErrorFallback({ message }: { message: string }): ReactNode {
  return <div>{message}</div>;
}

export async function ReadinessSection(): Promise<ReactNode> {
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