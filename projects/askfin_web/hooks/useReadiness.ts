// hooks/useReadiness.ts

'use client';

import { useState, useEffect } from 'react';
import { ReadinessData, isReadinessData } from '@/types/readiness';

export function useReadiness(userId: string) {
  const [data, setData] = useState<ReadinessData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchReadiness = async () => {
      try {
        const response = await fetch(`/api/users/${userId}/readiness`);
        if (!response.ok) throw new Error('Failed to load readiness');

        const json = await response.json();
        if (!isReadinessData(json)) {
          throw new Error('Invalid readiness data format');
        }

        setData(json);
        setError(null);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
        setData(null);
      } finally {
        setLoading(false);
      }
    };

    fetchReadiness();
  }, [userId]);

  return { data, loading, error };
}