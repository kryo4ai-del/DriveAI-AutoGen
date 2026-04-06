struct MemoryEvent: Identifiable, Codable {
    let id: UUID
    let questionId: String
    let timestamp: Date              // ← Precise timestamp — may be more than necessary
    let outcome: ReviewOutcome
    let responseTime: TimeInterval?  // ← Can reveal cognitive patterns
    let explanationViewed: Bool
}