// Services/Reminders/ReminderService.swift

import Foundation

@MainActor
protocol ReminderService: AnyObject, Sendable {
    // MARK: - State
    var reminders: [Reminder] { get }
    var preferences: ReminderPreferences { get }
    var isNotificationPermissionGranted: Bool { get }
    
    // MARK: - Lifecycle
    func initialize() async throws
    
    // MARK: - CRUD
    func createReminder(
        _ trigger: ReminderTrigger,
        action: ReminderAction
    ) async throws -> Reminder
    func listReminders() async throws -> [Reminder]
    func updateReminder(_ reminder: Reminder) async throws
    func deleteReminder(id: UUID) async throws
    func deleteAllReminders() async throws
    
    // MARK: - Preferences
    func loadPreferences() async throws
    func updatePreferences(_ prefs: ReminderPreferences) async throws
    func requestNotificationPermission() async -> Bool
    
    // MARK: - Scheduling
    func scheduleReminder(_ reminder: Reminder) async throws
    func evaluateTriggers() async throws
    func cancelScheduledReminders() async throws
    
    // MARK: - Manual Triggers
    func triggerExamFailedReminder(categoryName: String, score: Int) async throws
    func triggerStreakBrokenReminder() async throws
    func triggerWeakAreaReminder(categoryID: String) async throws
}