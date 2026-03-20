// types/readiness.ts
export function isReadinessData(value: unknown): value is ReadinessData {
  return validateReadinessData(value);
}

// Usage in hooks/services:
const response = await fetch('/api/readiness');
const data = await response.json();

if (!isReadinessData(data)) {
  throw new Error('Invalid readiness data structure');
}
// Now safe to use `data: ReadinessData`