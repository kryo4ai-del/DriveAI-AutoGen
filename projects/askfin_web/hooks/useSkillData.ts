'use client';

import { useCallback, useEffect, useRef, useState } from 'react';
import { SkillMapData } from '@/types/skill';

/**
 * Fetches skill data with automatic request cancellation
 * Prevents race conditions and stale data updates
 */
export function useSkillData(userId: string) {
  const [data, setData] = useState<SkillMapData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [retryCount, setRetryCount] = useState(0);
  const abortControllerRef = useRef<AbortController | null>(null);

  const retry = useCallback(() => {
    setRetryCount((count) => count + 1);
  }, []);

  useEffect(() => {
    // Cancel previous request
    abortControllerRef.current?.abort();
    abortControllerRef.current = new AbortController();

    async function fetchSkills() {
      try {
        setIsLoading(true);
        setError(null);

        const response = await fetch(`/api/skills/${userId}`, {
          signal: abortControllerRef.current?.signal,
        });

        if (!response.ok) {
          throw new Error(
            response.status === 404
              ? 'Fähigkeiten nicht gefunden'
              : 'Fehler beim Laden der Fähigkeiten'
          );
        }

        const json = await response.json();
        setData(json);
      } catch (err) {
        // Ignore AbortError from cancellation
        if (err instanceof Error && err.name !== 'AbortError') {
          setError(err.message || 'Unbekannter Fehler');
        }
      } finally {
        setIsLoading(false);
      }
    }

    fetchSkills();

    return () => {
      abortControllerRef.current?.abort();
    };
  }, [userId, retryCount]);

  return { data, isLoading, error, retry };
}