export function getProgressColor(progress: number): ProgressColorResult {
  if (progress < 33) {
    return {
      bar: 'bg-red-500',
      badge: 'bg-red-100 text-red-800',
      indicator: '●', // ✅ Good, but only in badge
    };
  }
  // ... rest
}

// In ProgressBar:
<div className={`h-full ${bar} ...`} /> // ❌ No visual pattern/pattern