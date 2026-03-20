// hooks/useExamResults.ts
'use client';

import { useState, useEffect, useCallback } from 'react';
import {
  ExamResult,
  ResultCategory,
  GapAnalysis,
} from '@/types/examResults';
import {
  fetchExamResult,
  calculateCategoryBreakdown,
  generateGapAnalysis,
} from '@/services/resultsService';

export interface UseExamResultsReturn {
  result: ExamResult | null;
  categoryBreakdown: ResultCategory[] | null;
  gapAnalysis: GapAnalysis | null;
  isLoading: boolean;
  error: string | null;
  refreshResults: () => Promise<void>;
}

export function useExamResults(sessionId: string): UseExamResultsReturn {
  const [result, setResult] = useState<ExamResult | null>(null);
  const [categoryBreakdown, setCategoryBreakdown] = useState<
    ResultCategory[] | null
  >(null);
  const [gapAnalysis, setGapAnalysis] = useState<GapAnalysis | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Load results—memoized to be stable for dependency arrays in parent
  const loadResults = useCallback(async () => {
    try {
      setIsLoading(true);
      setError(null);

      const examResult = await fetchExamResult(sessionId);
      setResult(examResult);

      const breakdown = await calculateCategoryBreakdown(examResult);
      setCategoryBreakdown(breakdown);

      const gaps = await generateGapAnalysis(examResult);
      setGapAnalysis(gaps);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : 'Failed to load results';
      setError(message);
    } finally {
      setIsLoading(false);
    }
  }, [sessionId]);

  // Load results on mount and when sessionId changes
  // Only sessionId in deps—loadResults is stable and doesn't trigger new fetches
  useEffect(() => {
    loadResults();
  }, [sessionId, loadResults]);

  return {
    result,
    categoryBreakdown,
    gapAnalysis,
    isLoading,
    error,
    refreshResults: loadResults,
  };
}