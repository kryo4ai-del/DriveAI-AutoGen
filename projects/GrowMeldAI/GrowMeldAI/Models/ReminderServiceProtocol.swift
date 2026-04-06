import Foundation
import Combine
import UserNotifications

protocol ReminderServiceProtocol {
    func scheduleReminder(for topic: WeakTopic) async throws -> Reminder
    func getPendingReminders() async -> [Reminder]
    func completeReminder(_ reminder: Reminder) async
    func getWeakTopics() async -> [WeakTopic]
    func updateWeakTopic(_ topic: WeakTopic) async
}
