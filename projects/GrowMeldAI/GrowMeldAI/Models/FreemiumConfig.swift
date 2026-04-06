// Features/Freemium/Models/FreemiumConfig.swift
struct FreemiumConfig: Equatable, Codable {
    let dailyQuotaLimit: Int
    let trialDurationDays: Int
    let gracePeriodHours: Int
    
    static let `default` = FreemiumConfig(
        dailyQuotaLimit: 5,
        trialDurationDays: 14,
        gracePeriodHours: 24
    )
    
    /// Can be overridden for testing or A/B testing
    static var current = FreemiumConfig.default
}

// Update FreemiumState.swift:
extension FreemiumState {
    var progressPercentage: Double {
        let config = FreemiumConfig.current
        
        switch self {
        case .unlimited, .trialExpired, .freeTierExhausted:
            return 0
        case .trialActive(let daysRemaining, _):
            return Double(daysRemaining) / Double(config.trialDurationDays)
        case .freeTierActive(let remaining):
            return Double(remaining) / Double(config.dailyQuotaLimit)
        }
    }
}

// TEST:
func test_progressPercentage_respectsConfig() throws {
    let originalConfig = FreemiumConfig.current
    defer { FreemiumConfig.current = originalConfig }
    
    FreemiumConfig.current = FreemiumConfig(
        dailyQuotaLimit: 10,
        trialDurationDays: 21,
        gracePeriodHours: 24
    )
    
    let state: FreemiumState = .freeTierActive(questionsRemaining: 5)
    XCTAssertEqual(state.progressPercentage, 0.5, "5 remaining / 10 limit = 50%")
}