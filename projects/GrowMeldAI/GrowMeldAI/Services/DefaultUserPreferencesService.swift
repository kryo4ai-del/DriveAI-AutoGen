import Foundation

final class DefaultUserPreferencesService: UserPreferencesService {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private static let reminderPreferenceKey = "com.driveai.reminder.preference"
    private static let userProgressKey = "com.driveai.user.progress"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveReminderPreference(enabled: Bool, hour: Int?, minute: Int?) throws {
        let preference = ReminderPreference(
            enabled: enabled,
            hour: hour,
            minute: minute,
            lastUpdated: Date()
        )
        
        do {
            let data = try encoder.encode(preference)
            userDefaults.set(data, forKey: Self.reminderPreferenceKey)
        } catch {
            throw ReminderError.encodingFailed
        }
    }
    
    func loadReminderPreference() -> ReminderPreference? {
        guard let data = userDefaults.data(forKey: Self.reminderPreferenceKey) else {
            return nil
        }
        
        do {
            return try decoder.decode(ReminderPreference.self, from: data)
        } catch {
            return nil
        }
    }
    
    func getUserProgress() async -> Int {
        // Simulated progress fetch — integrate with actual QuestionService
        let progress = userDefaults.integer(forKey: Self.userProgressKey)
        return max(0, min(100, progress))  // Clamp 0-100
    }
    
    func clearReminderPreference() throws {
        userDefaults.removeObject(forKey: Self.reminderPreferenceKey)
    }
}