// Models/Domain/ReminderAction.swift

import Foundation

enum ReminderAction: String, Codable, Hashable {
    case notifyAndScheduleReview
    case promptRetakeExam
    case encourageStreak
    case scheduleStudySession
    
    var localizationKey: String {
        "reminder.action.\(self.rawValue)"
    }
}