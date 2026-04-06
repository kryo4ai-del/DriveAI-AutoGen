import Foundation

/// Thread-safe representation of daily question quota
struct QuotaState: Codable, Equatable {
    let dailyLimit: Int
    var questionsConsumedToday: Int
    var lastResetDate: Date
    
    init(
        dailyLimit: Int = 20,
        questionsConsumedToday: Int = 0,
        lastResetDate: Date = Date()
    ) {
        self.dailyLimit = max(1, dailyLimit) // Ensure valid limit
        self.questionsConsumedToday = max(0, questionsConsumedToday)
        self.lastResetDate = lastResetDate
    }
    
    var remainingToday: Int {
        max(0, dailyLimit - questionsConsumedToday)
    }
    
    var quotaPercentage: Double {
        guard dailyLimit > 0 else { return 0 }
        return Double(questionsConsumedToday) / Double(dailyLimit)
    }
    
    var isExhausted: Bool {
        questionsConsumedToday >= dailyLimit
    }
    
    var isNearLimit: Bool {
        quotaPercentage >= 0.8
    }
}