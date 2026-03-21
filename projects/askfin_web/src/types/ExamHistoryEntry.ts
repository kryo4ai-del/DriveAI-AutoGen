export interface ExamHistoryEntry extends ExamResult {
  historyId: string; // Distinct from sessionId
}