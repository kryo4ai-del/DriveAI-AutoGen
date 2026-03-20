/**
 * Utility types for common patterns
 */

export type AnswerMap = Record<string, string>;

export interface TimeWindow {
  startTime: number;
  endTime?: number;
}

export function getElapsedTime(window: TimeWindow): number {
  return (window.endTime ?? Date.now()) - window.startTime;
}

export function isTimeExpired(
  startTime: number,
  duration: number
): boolean {
  return Date.now() - startTime > duration;
}