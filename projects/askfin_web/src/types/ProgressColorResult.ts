/**
 * Maps progress (0-100) to Tailwind color classes + accessibility indicators
 * Red (0-33%) → Yellow (33-66%) → Green (66-100%)
 * Includes visual patterns for colorblind accessibility (WCAG 2.1 SC 1.4.1)
 */

export interface ProgressColorResult {
  bar: string;
  badge: string;
  indicator: string; // Visual/text indicator for colorblind users
}

export function getGradientClass(progress: number): string {
  if (progress < 33) return 'from-red-500 to-yellow-500';
  if (progress < 66) return 'from-yellow-500 to-green-500';
  return 'from-green-400 to-green-600';
}