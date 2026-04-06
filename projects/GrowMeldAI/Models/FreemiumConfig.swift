import Foundation

struct FreemiumConfig: Equatable, Codable {
    let dailyQuotaLimit: Int
    let trialDurationDays: Int
    let gracePeriodHours: Int

    static let `default` = FreemiumConfig(
        dailyQuotaLimit: 5,
        trialDurationDays: 14,
        gracePeriodHours: 24
    )

    static var current = FreemiumConfig.default
}

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