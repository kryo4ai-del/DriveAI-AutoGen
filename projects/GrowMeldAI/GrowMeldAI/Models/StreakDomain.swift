import Foundation

struct StreakDomain: Codable, Equatable {
    let currentStreak: Int
    let maxStreak: Int
    var lastActivityDate: Date?
    
    var isActive: Bool {
        guard let lastActivityDate else { return false }
        let daysSinceActivity = Calendar.current.dateComponents(
            [.day],
            from: lastActivityDate,
            to: Date.now
        ).day ?? 0
        return daysSinceActivity < 2 // Allows 1 day gap
    }
    
    func nextResetDate(from lastActivity: Date) -> Date? {
        let resetThreshold = Calendar.current.date(byAdding: .day, value: 1, to: lastActivity)
        return resetThreshold
    }
}