struct RecommendedQuestion: Codable, Identifiable {
    let id: String
    let category: String
    let urgency: PlanUrgency       // ← Enum, no label
    let spaceInterval: Int          // ← Raw number, no context
    let retrievalStrength: Double   // ← Decimal 0-1, meaningless to users
    let failureRate: Double         // ← 0.35 instead of "35%"
    let emotionalContext: String?   // ← Only English context, not localized
}