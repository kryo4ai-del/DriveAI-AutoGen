struct TrialJourney: Codable, Equatable {
    var daysRemaining: Int { /* computed */ }
    var isTrialActive: Bool { /* computed */ }
    var hasExceededQuotaToday: Bool { /* computed */ }
}