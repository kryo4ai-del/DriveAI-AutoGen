export interface AccessibleResult extends ExamResult {
  timeSpentFormatted: string; // "2 minutes 5 seconds"
  timeSpentSeconds: number; // Semantic value
  readableSubmitTime: string; // "2025-03-20, 2:45 PM"
}

// Add method:
static getAccessibleResult(result: ExamResult): AccessibleResult {
  const minutes = Math.floor(result.timeSpent / 60000);
  const seconds = (result.timeSpent % 60000) / 1000;
  
  return {
    ...result,
    timeSpentFormatted: `${minutes} ${minutes === 1 ? 'minute' : 'minutes'} ${Math.round(seconds)} seconds`,
    timeSpentSeconds: Math.floor(result.timeSpent / 1000),
    readableSubmitTime: new Date(result.submittedAt).toLocaleString(),
  };
}