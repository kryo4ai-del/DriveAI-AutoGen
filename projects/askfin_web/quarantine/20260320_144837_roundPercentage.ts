// Create utility
export function roundPercentage(value: number, decimals: number = 2): number {
  const factor = Math.pow(10, decimals);
  return Math.round(value * factor) / factor;
}

// Apply consistently
const weaknessScore = 100 - (recentAccuracy * 0.6 + accuracy * 0.4);
return {
  weaknessScore: roundPercentage(weaknessScore),
  accuracy: roundPercentage(accuracy),
};