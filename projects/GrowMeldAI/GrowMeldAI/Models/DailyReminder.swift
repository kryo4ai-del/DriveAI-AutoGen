import Foundation

/// Represents a user-scheduled daily reminder for learning motivation.
/// Designed for offline-first storage; supports future backend sync.
struct DailyReminder: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let scheduledTime: Date // HH:MM component (date part ignored)
    var isEnabled: Bool
    var streakThreshold: Int? // Optional: skip if ≥N questions answered today
    let createdAt: Date
    var consentGivenAt: Date? // Privacy: when user consented to notifications
    
    init(
        id: UUID = UUID(),
        scheduledTime: Date,
        isEnabled: Bool = true,
        streakThreshold: Int? = nil,
        createdAt: Date = .now,
        consentGivenAt: Date? = nil
    ) {
        self.id = id
        self.scheduledTime = scheduledTime
        self.isEnabled = isEnabled
        self.streakThreshold = streakThreshold
        self.createdAt = createdAt
        self.consentGivenAt = consentGivenAt
    }
    
    // MARK: - Computed Properties
    
    /// Returns time in HH:MM format (e.g., "08:00").
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: scheduledTime)
    }
    
    /// Returns next trigger date (DateComponents) for calendar notification.
    var nextTriggerDate: DateComponents {
        ReminderScheduler.nextTriggerDate(for: self)
    }
}