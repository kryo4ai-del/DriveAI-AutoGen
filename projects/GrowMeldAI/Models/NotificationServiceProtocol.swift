// Services/Notifications/NotificationServiceProtocol.swift
import UserNotifications
import Foundation

protocol NotificationServiceProtocol: Sendable {
    func requestUserPermission() async -> UNAuthorizationStatus
    func checkCurrentPermissionStatus() async -> UNAuthorizationStatus
    func scheduleStudyReminder(for date: Date, message: String) async throws
    func cancelAllPendingNotifications() async
    func isNotificationEnabled() -> Bool
}

// Mock for testing: