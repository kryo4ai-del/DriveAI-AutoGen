export interface AccessibleRecommendation extends Recommendation {
  actionItemsStructured: Array<{
    index: number;
    text: string;
    estimatedTime?: number; // minutes to complete
    priority: 'high' | 'medium' | 'low';
  }>;
}

// Modify GapAnalysisService:
static analyzeResults(result: ExamResult): GapAnalysisReport {
  const recommendations = this.generateRecommendations(weakCategories)
    .map((rec, idx) => ({
      ...rec,
      actionItemsStructured: rec.actionItems.map((text, itemIdx) => ({
        index: itemIdx + 1,
        text,
        priority: rec.severity === 'critical' ? 'high' : 'medium',
      })),
    }));

  // ... rest of logic
}