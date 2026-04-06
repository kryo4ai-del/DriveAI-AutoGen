// Models/Notifications/NotificationSchedule.swift
import Foundation

struct NotificationSchedule: Codable, Equatable {
    let trigger: NotificationTrigger
    let frequency: NotificationFrequency
    let nextScheduledDate: Date?
    let isEnabled: Bool

    enum NotificationFrequency: String, Codable {
        case once
        case daily
        case weekly
    }
}