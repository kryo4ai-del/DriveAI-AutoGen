struct RetentionTrigger {
    let questionId: UUID
    let triggerDate: Date           // 1, 3, or 7 days from correct answer
    let triggerReason: String       // "Maintain your knowledge"
    let isMaintenanceReview: Bool   // Not "failure", just "keep sharp"
}

extension LocalDataService {
    /// When should this question trigger a review notification?
    func scheduleRetentionTrigger(
        questionId: UUID,
        lastCorrectDate: Date
    ) -> RetentionTrigger {
        // Spacing: 1 day, 3 days, 7 days
        let spacingIntervals: [TimeInterval] = [1, 3, 7].map { $0 * 24 * 3600 }
        
        // Find the next due interval
        let nextTriggerDate = spacingIntervals.first { interval in
            lastCorrectDate.addingTimeInterval(interval) <= Date()
        }.map { lastCorrectDate.addingTimeInterval($0) } ?? lastCorrectDate.addingTimeInterval(24 * 3600)
        
        return RetentionTrigger(
            questionId: questionId,
            triggerDate: nextTriggerDate,
            triggerReason: "Dein Wissen auffallen? Diese Frage war vor 3 Tagen richtig.",
            isMaintenanceReview: true
        )
    }
}