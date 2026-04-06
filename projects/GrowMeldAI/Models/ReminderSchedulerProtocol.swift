import Foundation
import UserNotifications

// MARK: - Protocol

protocol ReminderSchedulerProtocol {
    func scheduleReminder(_ config: ReminderConfiguration) async throws
    func cancelReminder(_ id: UUID) async throws
}

// MARK: - Supporting Types

// Struct ReminderConfiguration declared in Models/ReminderConfiguration.swift

// MARK: - Mock Implementations (for testing only)

class MockReminderScheduler: ReminderSchedulerProtocol {
    var scheduleWasCalled = false
    var cancelWasCalled = false
    var lastScheduledConfig: ReminderConfiguration?
    var lastCancelledId: UUID?

    func scheduleReminder(_ config: ReminderConfiguration) async throws {
        scheduleWasCalled = true
        lastScheduledConfig = config
    }

    func cancelReminder(_ id: UUID) async throws {
        cancelWasCalled = true
        lastCancelledId = id
    }
}