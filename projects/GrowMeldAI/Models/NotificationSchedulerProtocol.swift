// Services/RemindersService/NotificationScheduler.swift (NEW FILE)
// Extract scheduling logic into dedicated service layer

import Foundation
import UserNotifications

protocol NotificationSchedulerProtocol {
    func scheduleNotifications(
        baseId: String,
        time: Date,
        frequency: ReminderFrequency,
        title: String,
        body: String
    ) throws
    
    func cancelAllNotifications(baseId: String, frequency: ReminderFrequency)
}
