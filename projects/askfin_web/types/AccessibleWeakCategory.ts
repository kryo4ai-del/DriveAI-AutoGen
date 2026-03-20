export interface AccessibleWeakCategory extends WeakCategory {
  percentageDescription: string; // Semantic description
  scoreComparison: string; // "Below passing (70%)"
}

// Add method:
private static getPercentageDescription(percentage: number): string {
  if (percentage < 20) return 'very weak understanding';
  if (percentage < 40) return 'limited understanding';
  if (percentage < 60) return 'partial understanding';
  if (percentage < 80) return 'strong understanding';
  return 'excellent understanding';
}

private static getScoreComparison(percentage: number, threshold: number): string {
  const diff = Math.abs(percentage - threshold);
  if (percentage >= threshold) {
    return `Exceeds passing threshold by ${diff}%`;
  }
  return `${diff}% below passing threshold (${threshold}%)`;
}