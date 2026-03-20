/**
 * INVARIANT: All questionIds in userAnswers must exist in questions array.
 * Enforce at repository layer.
 */

// ---

/**
 * INVARIANT: selectedAnswerIndex must be in range [0, Question.answers.length - 1]
 * Enforce at answer submission layer before persisting.
 */

// ---

---

### 6. **IQuestionRepository Missing Error Handling** (Medium)
**File:** `types/trainingMode.ts` — `IQuestionRepository` interface  
**Problem:** All methods return `Promise<T>` but no spec for error cases. What if DB is down? Question not found? No error type defined.

**Impact:** Implementations throw untyped errors; callers can't handle gracefully.

**Fix:**

// ---

import { describe, it, expect } from 'vitest';
import {
  TrainingMode,
  QuestionCategory,
  DifficultyLevel,
  createTimestamp,
  now,
  getElapsedMs,
  isHarderDifficulty,
  getNextDifficulty,
} from '@/types/trainingMode';

describe('TrainingMode Enums', () => {
  describe('TrainingMode', () => {
    it('should have three distinct modes', () => {
      expect(Object.values(TrainingMode)).toHaveLength(3);
      expect(TrainingMode.DAILY).toBe('daily');
      expect(TrainingMode.TOPIC).toBe('topic');
      expect(TrainingMode.WEAKNESS).toBe('weakness');
    });

    it('should be usable as discriminator in unions', () => {
      type TrainingConfig = 
        | { mode: TrainingMode.DAILY }
        | { mode: TrainingMode.TOPIC; category: QuestionCategory }
        | { mode: TrainingMode.WEAKNESS };

      const config: TrainingConfig = { mode: TrainingMode.TOPIC, category: QuestionCategory.VORFAHRT };
      expect(config.mode).toBe(TrainingMode.TOPIC);
    });
  });

  describe('QuestionCategory', () => {
    it('should contain all German StVO categories', () => {
      const categories = Object.values(QuestionCategory);
      expect(categories).toContain('vorfahrt');
      expect(categories).toContain('verkehrszeichen');
      expect(categories).toContain('technik');
      expect(categories).toContain('verhalten');
      expect(categories).toContain('umwelt');
      expect(categories).toContain('erste_hilfe');
      expect(categories).toContain('gefahrenerkennung');
    });

    it('should map category values consistently', () => {
      expect(QuestionCategory.VORFAHRT).toBe('vorfahrt');
      expect(QuestionCategory.VERKEHRSZEICHEN).toBe('verkehrszeichen');
    });
  });

  describe('DifficultyLevel (Ordered)', () => {
    it('should have numeric values for ordering', () => {
      expect(DifficultyLevel.EASY).toBe(0);
      expect(DifficultyLevel.MEDIUM).toBe(1);
      expect(DifficultyLevel.HARD).toBe(2);
    });

    it('should support numeric comparison', () => {
      expect(DifficultyLevel.EASY < DifficultyLevel.MEDIUM).toBe(true);
      expect(DifficultyLevel.HARD > DifficultyLevel.EASY).toBe(true);
    });

    it('should use isHarderDifficulty() for clarity', () => {
      expect(isHarderDifficulty(DifficultyLevel.HARD, DifficultyLevel.EASY)).toBe(true);
      expect(isHarderDifficulty(DifficultyLevel.MEDIUM, DifficultyLevel.MEDIUM)).toBe(false);
      expect(isHarderDifficulty(DifficultyLevel.EASY, DifficultyLevel.HARD)).toBe(false);
    });

    it('should provide getNextDifficulty() helper', () => {
      expect(getNextDifficulty(DifficultyLevel.EASY)).toBe(DifficultyLevel.MEDIUM);
      expect(getNextDifficulty(DifficultyLevel.MEDIUM)).toBe(DifficultyLevel.HARD);
      expect(getNextDifficulty(DifficultyLevel.HARD)).toBeNull();
    });
  });
});

describe('Timestamp Type & Helpers', () => {
  describe('createTimestamp()', () => {
    it('should create ISO 8601 timestamp from Date', () => {
      const date = new Date('2025-03-19T14:30:00.123Z');
      const ts = createTimestamp(date);
      expect(ts).toBe('2025-03-19T14:30:00.123Z');
    });

    it('should create ISO 8601 timestamp from string', () => {
      const isoString = '2025-03-19T14:30:00.123Z';
      const ts = createTimestamp(isoString);
      expect(ts).toBe(isoString);
    });

    it('should default to current time', () => {
      const before = new Date();
      const ts = createTimestamp();
      const after = new Date();

      const tsDate = new Date(ts);
      expect(tsDate.getTime()).toBeGreaterThanOrEqual(before.getTime());
      expect(tsDate.getTime()).toBeLessThanOrEqual(after.getTime());
    });
  });

  describe('now()', () => {
    it('should return current ISO 8601 timestamp', () => {
      const ts = now();
      expect(ts).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/);
    });

    it('should be valid for Date constructor', () => {
      const ts = now();
      const date = new Date(ts);
      expect(date instanceof Date).toBe(true);
      expect(date.getTime()).toBeGreaterThan(0);
    });
  });

  describe('getElapsedMs()', () => {
    it('should calculate elapsed milliseconds correctly', () => {
      const start = createTimestamp(new Date('2025-03-19T14:30:00.000Z'));
      const end = createTimestamp(new Date('2025-03-19T14:30:05.000Z'));

      expect(getElapsedMs(start, end)).toBe(5000);
    });

    it('should handle millisecond precision', () => {
      const start = createTimestamp(new Date('2025-03-19T14:30:00.000Z'));
      const end = createTimestamp(new Date('2025-03-19T14:30:00.123Z'));

      expect(getElapsedMs(start, end)).toBe(123);
    });

    it('should handle negative elapsed (end before start)', () => {
      const start = createTimestamp(new Date('2025-03-19T14:30:10.000Z'));
      const end = createTimestamp(new Date('2025-03-19T14:30:00.000Z'));

      expect(getElapsedMs(start, end)).toBe(-10000);
    });

    it('should return 0 for same timestamps', () => {
      const ts = now();
      expect(getElapsedMs(ts, ts)).toBe(0);
    });
  });
});

describe('Type Narrowing & Discriminators', () => {
  it('should narrow TrainingMode in switch statement', () => {
    const mode = TrainingMode.TOPIC;
    let result: string;

    switch (mode) {
      case TrainingMode.DAILY:
        result = 'daily-training';
        break;
      case TrainingMode.TOPIC:
        result = 'topic-training';
        break;
      case TrainingMode.WEAKNESS:
        result = 'weakness-training';
        break;
      default:
        const _exhaustive: never = mode;
        result = _exhaustive;
    }

    expect(result).toBe('topic-training');
  });

  it('should enforce exhaustiveness check for enums', () => {
    // TypeScript will error if TrainingMode is extended but not handled
    const handleMode = (mode: TrainingMode): string => {
      switch (mode) {
        case TrainingMode.DAILY:
          return 'daily';
        case TrainingMode.TOPIC:
          return 'topic';
        case TrainingMode.WEAKNESS:
          return 'weakness';
      }
    };

    expect(handleMode(TrainingMode.DAILY)).toBe('daily');
  });
});