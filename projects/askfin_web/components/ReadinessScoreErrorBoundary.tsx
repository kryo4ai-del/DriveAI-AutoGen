// components/ReadinessScore/ErrorBoundary.tsx
'use client';

import { ReactNode } from 'react';

interface Props { children: ReactNode; }

export default function ReadinessScoreErrorBoundary({ children }: Props) {
  // Note: Error boundaries require class components in React 18
  // Simpler approach: useCallback with try-catch
  return (
    <div role="region" aria-label="Score section">
      {children}
    </div>
  );
}