// MARK: - Services/Persistence/UserDefaultsManager.swift
import Foundation

final class UserDefaultsManager {
    private let defaults = UserDefaults.standard
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private enum Keys {
        static let onboardingComplete = "onboarding_complete"
        static let examDate = "exam_date"
        static let userProgress = "user_progress_"
        static let lastActiveDate = "last_active_date"
        static let reviewSchedule = "review_schedule_"
    }
    
    // MARK: - Onboarding
    var isOnboardingComplete: Bool {
        defaults.bool(forKey: Keys.onboardingComplete)
    }
    
    func setOnboardingComplete(_ value: Bool) {
        defaults.set(value, forKey: Keys.onboardingComplete)
    }
    
    var examDate: Date? {
        defaults.object(forKey: Keys.examDate) as? Date
    }
    
    func setExamDate(_ date: Date) {
        defaults.set(date, forKey: Keys.examDate)
    }
    
    // MARK: - Progress Tracking
    func saveProgress(_ progress: UserProgress) throws {
        let data = try encoder.encode(progress)
        defaults.set(data, forKey: Keys.userProgress + progress.categoryId)
    }
    
    func fetchProgress(categoryId: String) throws -> UserProgress {
        guard let data = defaults.data(forKey: Keys.userProgress + categoryId) else {
            return UserProgress(categoryId: categoryId)
        }
        return try decoder.decode(UserProgress.self, from: data)
    }
    
    // MARK: - Streak Tracking
    func getLastActiveDate() -> Date? {
        defaults.object(forKey: Keys.lastActiveDate) as? Date
    }
    
    func updateLastActiveDate() {
        defaults.set(Date(), forKey: Keys.lastActiveDate)
    }
    
    func calculateStreak() -> Int {
        guard let lastActive = getLastActiveDate() else { return 0 }
        
        let calendar = Calendar.current
        let daysAgo = calendar.dateComponents([.day], from: lastActive, to: Date()).day ?? 0
        
        if daysAgo == 0 {
            return (defaults.integer(forKey: "current_streak") > 0) ? defaults.integer(forKey: "current_streak") : 1
        } else if daysAgo == 1 {
            let newStreak = defaults.integer(forKey: "current_streak") + 1
            defaults.set(newStreak, forKey: "current_streak")
            return newStreak
        } else {
            defaults.set(1, forKey: "current_streak")
            return 1
        }
    }
}