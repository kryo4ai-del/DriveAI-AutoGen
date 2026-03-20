/**
 * API response wrapper for all backend endpoints
 * @example
 * const response: ApiResponse<Question[]> = await fetch('/api/questions')
 */
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  timestamp: number;
}