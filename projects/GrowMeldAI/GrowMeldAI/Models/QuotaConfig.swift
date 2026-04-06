import Foundation

/// Single source of truth for quota thresholds
public struct QuotaConfig {
    public let dailyQuestionLimit: Int
    public let weeklyQuestionLimit: Int
    public let monthlyQuestionLimit: Int
    public let premiumMultiplier: Double
    
    public static let `default` = QuotaConfig(
        dailyQuestionLimit: 5,
        weeklyQuestionLimit: 25,
        monthlyQuestionLimit: 100,
        premiumMultiplier: 3.0
    )
    
    public func limit(for period: QuotaPeriod, isPremium: Bool) -> Int {
        let baseLimit = switch period {
        case .daily: dailyQuestionLimit
        case .weekly: weeklyQuestionLimit
        case .monthly: monthlyQuestionLimit
        }
        return isPremium ? Int(Double(baseLimit) * premiumMultiplier) : baseLimit
    }
}

public enum QuotaPeriod: Hashable {
    case daily
    case weekly
    case monthly
}

public struct QuotaUsage {
    public let period: QuotaPeriod
    public let used: Int
    public let limit: Int
    public let resetDate: Date
    
    public var remaining: Int {
        max(0, limit - used)
    }
    
    public var percentageUsed: Double {
        guard limit > 0 else { return 0 }
        return Double(used) / Double(limit)
    }
    
    public var isExhausted: Bool {
        used >= limit
    }
    
    public var approachLevel: LimitApproachLevel {
        let percentage = percentageUsed
        
        if percentage >= 0.9 {
            return .critical
        } else if percentage >= 0.7 {
            return .warning
        } else {
            return .healthy
        }
    }
}
