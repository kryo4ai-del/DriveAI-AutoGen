import Foundation
import Combine

protocol RemindersServiceProtocol {
    func scheduleReminder(at time: Date, frequency: ReminderFrequency) -> AnyPublisher<UUID, RemindersError>
    func cancelReminder(id: UUID) -> AnyPublisher<Void, RemindersError>
    func updateReminderTime(id: UUID, newTime: Date) -> AnyPublisher<Void, RemindersError>
    func fetchScheduledReminders() -> AnyPublisher<[ReminderModel], RemindersError>
    func requestNotificationPermission() -> AnyPublisher<Bool, Never>
    func getAuthorizationStatus() -> AnyPublisher<UNAuthorizationStatus, Never>
}
