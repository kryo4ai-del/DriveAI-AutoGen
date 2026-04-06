// Services/Reminders/ReminderError.swift
import Foundation

enum ReminderError: LocalizedError {
    case reminderNotFound
    case notificationSchedulingFailed(Error)
    case persistenceFailed(Error)
    case decodingFailed(Error)
    case invalidTriggerDate
    
    var errorDescription: String? {
        switch self {
        case .reminderNotFound:
            return NSLocalizedString("error.reminder.not_found", comment: "")
        case .notificationSchedulingFailed(let error):
            return String(format: NSLocalizedString("error.reminder.scheduling_failed", comment: ""), error.localizedDescription)
        case .persistenceFailed(let error):
            return String(format: NSLocalizedString("error.reminder.persistence_failed", comment: ""), error.localizedDescription)
        case .decodingFailed(let error):
            return String(format: NSLocalizedString("error.reminder.decoding_failed", comment: ""), error.localizedDescription)
        case .invalidTriggerDate:
            return NSLocalizedString("error.reminder.invalid_trigger_date", comment: "")
        }
    }
}