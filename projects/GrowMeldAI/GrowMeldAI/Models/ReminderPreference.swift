import Foundation

/// User's reminder settings and preferences
struct ReminderPreference: Codable {
    var isEnabled: Bool
    var preferredTime: Date // Time of day
    var frequency: ReminderFrequency
    var timezone: TimeZone
    var soundEnabled: Bool
    var badgeEnabled: Bool
    var lastModified: Date
    
    init(
        isEnabled: Bool = false,
        preferredTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
        frequency: ReminderFrequency = .daily,
        timezone: TimeZone = TimeZone.current,
        soundEnabled: Bool = true,
        badgeEnabled: Bool = true,
        lastModified: Date = Date()
    ) {
        self.isEnabled = isEnabled
        self.preferredTime = preferredTime
        self.frequency = frequency
        self.timezone = timezone
        self.soundEnabled = soundEnabled
        self.badgeEnabled = badgeEnabled
        self.lastModified = lastModified
    }
}