class FeedbackEscalationService {
    func getFlaggedFeedback(severity: FeedbackSeverity) async -> [UserFeedback]
    func markAsReviewed(id: UUID, notes: String) async throws
    func getEscalationMetrics() -> EscalationMetrics
}