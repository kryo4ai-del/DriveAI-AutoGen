import { SkillMapData } from '@/types/skillmap';

const API_BASE = process.env.NEXT_PUBLIC_API_URL || '/api';

/**
 * Type guard: validate response matches SkillMapData contract
 */
function isValidSkillMapData(data: unknown): data is SkillMapData {
  if (typeof data !== 'object' || data === null) {
    return false;
  }

  const obj = data as Record<string, unknown>;

  return (
    typeof obj.userId === 'string' &&
    Array.isArray(obj.categories) &&
    typeof obj.overallProficiency === 'number' &&
    obj.overallProficiency >= 0 &&
    obj.overallProficiency <= 1 &&
    typeof obj.lastRefreshed === 'string'
  );
}

/**
 * Fetch skill map data from API
 * Validates response shape before returning
 *
 * @throws Error if network fails or response is invalid
 */
export async function fetchSkillMap(): Promise<SkillMapData> {
  const response = await fetch(`${API_BASE}/skillmap`, {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
    cache: 'no-store',
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch skill map: ${response.status} ${response.statusText}`);
  }

  let data: unknown;
  try {
    data = await response.json();
  } catch (err) {
    throw new Error('Invalid JSON response from skill map API');
  }

  if (!isValidSkillMapData(data)) {
    console.error('Invalid skill map response:', data);
    throw new Error('Skill map response missing required fields: userId, categories, overallProficiency, lastRefreshed');
  }

  return data;
}

/**
 * Refresh skill map after training session
 * Validates response shape before returning
 *
 * @param trainingSessionId - ID of completed training session
 * @throws Error if network fails or response is invalid
 */
export async function refreshSkillMapAfterTraining(
  trainingSessionId: string
): Promise<SkillMapData> {
  if (!trainingSessionId.trim()) {
    throw new Error('Training session ID is required');
  }

  const response = await fetch(`${API_BASE}/skillmap/refresh`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ trainingSessionId }),
  });

  if (!response.ok) {
    throw new Error(
      `Failed to refresh skill map: ${response.status} ${response.statusText}`
    );
  }

  let data: unknown;
  try {
    data = await response.json();
  } catch (err) {
    throw new Error('Invalid JSON response from skill map refresh API');
  }

  if (!isValidSkillMapData(data)) {
    console.error('Invalid skill map refresh response:', data);
    throw new Error(
      'Skill map refresh response missing required fields: userId, categories, overallProficiency, lastRefreshed'
    );
  }

  return data;
}