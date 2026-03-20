export const VALID_CATEGORIES = new Set(Object.values(QuestionCategory));

export function assertValidCategory(cat: unknown): asserts cat is QuestionCategory {
  if (typeof cat !== "string" || !VALID_CATEGORIES.has(cat as QuestionCategory)) {
    throw new Error(`Invalid category: ${cat}`);
  }
}

// In data fetch:
const data = await fetch("/api/questions").then(r => r.json());
data.forEach(q => assertValidCategory(q.category));