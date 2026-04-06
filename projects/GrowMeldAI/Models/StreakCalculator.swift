final class StreakCalculator {
    private let userDefaults: UserDefaults
    private let calendar: Calendar
    
    private enum Keys {
        static let lastActiveDate = "streak_last_active_date"
        static let currentStreak = "streak_current_count"
    }
    
    init(userDefaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.userDefaults = userDefaults
        self.calendar = calendar
    }
    
    /// Thread-safe streak calculation
    func updateAndGetStreak() -> Int {
        let today = calendar.startOfDay(for: Date())
        let lastActiveDay = userDefaults.object(forKey: Keys.lastActiveDate)
            .flatMap { $0 as? Date }
            .map { calendar.startOfDay(for: $0) }
        
        // Case 1: First activity today → keep streak
        if lastActiveDay == today {
            let current = userDefaults.integer(forKey: Keys.currentStreak)
            return current > 0 ? current : 1
        }
        
        // Case 2: Activity yesterday → increment streak
        if lastActiveDay == calendar.date(byAdding: .day, value: -1, to: today) {
            let newStreak = (userDefaults.integer(forKey: Keys.currentStreak) ?? 0) + 1
            userDefaults.set(newStreak, forKey: Keys.currentStreak)
            userDefaults.set(today, forKey: Keys.lastActiveDate)
            return newStreak
        }
        
        // Case 3: Gap > 1 day → reset streak
        let newStreak = 1
        userDefaults.set(newStreak, forKey: Keys.currentStreak)
        userDefaults.set(today, forKey: Keys.lastActiveDate)
        return newStreak
    }
    
    func getCurrentStreak() -> Int {
        // Non-mutating read
        userDefaults.integer(forKey: Keys.currentStreak).max(with: 0)
    }
    
    func resetStreak() {
        userDefaults.removeObject(forKey: Keys.currentStreak)
        userDefaults.removeObject(forKey: Keys.lastActiveDate)
    }
}