import Foundation

/// Represents user's learning streak (current consecutive days & personal best).
/// Immutable value type. Thread-safe. Timezone-safe date calculations.
struct LearningStreak: Codable {
    var currentDays: Int
    var longestDays: Int
    var lastActiveDate: Date
    
    // MARK: - Computed Properties
    
    /// Whether user was active today (for UI badges and prompts).
    var isActiveToday: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        let lastActive = Calendar.current.startOfDay(for: lastActiveDate)
        return today == lastActive
    }
    
    /// Whether streak is at risk (no activity yesterday, resets tomorrow if no activity).
    /// Used to show motivational warnings.
    var isAtRisk: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let lastActive = Calendar.current.startOfDay(for: lastActiveDate)
        
        // At risk if last activity was before yesterday
        return lastActive < yesterday
    }
    
    /// Localized human-readable text about last activity.
    /// Examples: "Heute aktiv", "Gestern aktiv", "Vor 3 Tagen aktiv", "Nicht aktiv".
    var lastActiveText: String {
        let today = Calendar.current.startOfDay(for: .now)
        let lastActive = Calendar.current.startOfDay(for: lastActiveDate)
        
        guard let daysDiff = Calendar.current.dateComponents([.day], from: lastActive, to: today).day else {
            return NSLocalizedString("streak_unknown", comment: "Unknown streak status")
        }
        
        switch daysDiff {
        case 0:
            return NSLocalizedString("streak_active_today", comment: "Active today")
        case 1:
            return NSLocalizedString("streak_active_yesterday", comment: "Active yesterday")
        case 2...6:
            let formatted = String(format: NSLocalizedString("streak_active_days_ago", comment: ""), daysDiff)
            return formatted
        default:
            return NSLocalizedString("streak_not_active", comment: "Not recently active")
        }
    }
    
    // MARK: - Initializers
    
    init(
        currentDays: Int = 0,
        longestDays: Int = 0,
        lastActiveDate: Date = .now
    ) {
        precondition(currentDays >= 0, "currentDays must be non-negative")
        precondition(longestDays >= 0, "longestDays must be non-negative")
        
        self.currentDays = currentDays
        self.longestDays = longestDays
        self.lastActiveDate = lastActiveDate
    }
    
    // MARK: - Mutations (Value Semantics)
    
    /// Updates streak after user answers a question correctly.
    /// Handles three cases:
    /// 1. Same day: no change (already active today)
    /// 2. Consecutive day: increment current streak
    /// 3. Gap (≥2 days): reset current streak to 1
    ///
    /// - Returns: New `LearningStreak` with updated counters.
    func updateAfterCorrectAnswer() -> LearningStreak {
        let today = Calendar.current.startOfDay(for: .now)
        let lastActive = Calendar.current.startOfDay(for: lastActiveDate)
        
        // Case 1: Same day — already active, no change
        if today == lastActive {
            return self
        }
        
        // Case 2: Consecutive day — increment streak
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: lastActive)!
        if today == nextDay {
            let newCurrent = currentDays + 1
            let newLongest = max(newCurrent, longestDays)
            
            return LearningStreak(
                currentDays: newCurrent,
                longestDays: newLongest,
                lastActiveDate: .now
            )
        }
        
        // Case 3: Gap (≥2 days) — reset current streak
        return LearningStreak(
            currentDays: 1,
            longestDays: longestDays,
            lastActiveDate: .now
        )
    }
    
    /// Manually resets current streak (e.g., user acknowledges missed days).
    /// Preserves longest streak.
    ///
    /// - Returns: New `LearningStreak` with `currentDays = 0`.
    func reset() -> LearningStreak {
        LearningStreak(
            currentDays: 0,
            longestDays: longestDays,
            lastActiveDate: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now
        )
    }
}

// MARK: - Preview & Test Data

#if DEBUG
extension LearningStreak {
    /// Active today with 14-day streak.
    static let preview = LearningStreak(
        currentDays: 14,
        longestDays: 30,
        lastActiveDate: .now
    )
    
    /// Healthy: 7-day streak, was active today.
    static let activeToday = LearningStreak(
        currentDays: 7,
        longestDays: 21,
        lastActiveDate: .now
    )
    
    /// At risk: 5-day streak, but no activity yesterday.
    static let atRisk = LearningStreak(
        currentDays: 5,
        longestDays: 15,
        lastActiveDate: Date(timeIntervalSinceNow: -86400)  // 1 day ago
    )
    
    /// Broken: streak reset after gap, but personal best is 30 days.
    static let broken = LearningStreak(
        currentDays: 0,
        longestDays: 30,
        lastActiveDate: Date(timeIntervalSinceNow: -172800)  // 2 days ago
    )
    
    /// Just started.
    static let newUser = LearningStreak(
        currentDays: 1,
        longestDays: 1,
        lastActiveDate: .now
    )
}
#endif