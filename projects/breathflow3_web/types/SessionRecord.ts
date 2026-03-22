import { BreathingTechniqueType } from '@/types/BreathingTechnique';

export interface SessionRecord {
  id: string;
  techniqueId: BreathingTechniqueType;
  duration: number; // seconds
  timestamp: string; // ISO string
}

const STORAGE_KEY = 'breathflow_sessions';

export async function recordSession(session: {
  techniqueId: BreathingTechniqueType;
  duration: number;
  timestamp: Date;
}): Promise<void> {
  if (typeof window === 'undefined') return; // SSR guard

  try {
    const existing: SessionRecord[] = JSON.parse(
      localStorage.getItem(STORAGE_KEY) || '[]'
    );
    
    const newSession: SessionRecord = {
      id: crypto.randomUUID(),
      techniqueId: session.techniqueId,
      duration: session.duration,
      timestamp: session.timestamp.toISOString(),
    };
    
    existing.push(newSession);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(existing));
  } catch (error) {
    console.error('[BreathFlow] Failed to record session:', error);
  }
}

export function getWeeklySeconds(): number {
  if (typeof window === 'undefined') return 0;

  try {
    const sessions: SessionRecord[] = JSON.parse(
      localStorage.getItem(STORAGE_KEY) || '[]'
    );
    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

    return sessions
      .filter((s) => new Date(s.timestamp) > weekAgo)
      .reduce((sum, s) => sum + s.duration, 0);
  } catch {
    return 0;
  }
}

export function getSessions(): SessionRecord[] {
  if (typeof window === 'undefined') return [];
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]');
  } catch {
    return [];
  }
}