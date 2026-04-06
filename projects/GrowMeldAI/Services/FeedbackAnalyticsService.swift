class FeedbackAnalyticsService {
    func trackSubmitted(category: FeedbackCategory, online: Bool)
    func trackSyncSuccess(feedbackID: UUID)
    func trackSyncFailure(feedbackID: UUID, error: Error)
    func trackEscalation(category: FeedbackCategory, severity: FeedbackSeverity)
    func trackDeleted(feedbackID: UUID)
}