import Foundation

protocol RemindersPersistenceProtocol {
    func saveReminder(_ reminder: ReminderModel) throws
    func deleteReminder(id: UUID) throws
    func fetchReminder(id: UUID) throws -> ReminderModel?
    func fetchAllReminders() throws -> [ReminderModel]
}

final class RemindersPersistence: RemindersPersistenceProtocol {
    static let shared = RemindersPersistence()
    
    private let userDefaults = UserDefaults.standard
    private let remindersKey = "driveai_reminders"
    
    func saveReminder(_ reminder: ReminderModel) throws {
        var reminders = (try? fetchAllReminders()) ?? []
        
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        } else {
            reminders.append(reminder)
        }
        
        let encoded = try JSONEncoder().encode(reminders)
        userDefaults.set(encoded, forKey: remindersKey)
    }
    
    func deleteReminder(id: UUID) throws {
        var reminders = try fetchAllReminders()
        reminders.removeAll { $0.id == id }
        
        let encoded = try JSONEncoder().encode(reminders)
        userDefaults.set(encoded, forKey: remindersKey)
    }
    
    func fetchReminder(id: UUID) throws -> ReminderModel? {
        let reminders = try fetchAllReminders()
        return reminders.first { $0.id == id }
    }
    
    func fetchAllReminders() throws -> [ReminderModel] {
        guard let data = userDefaults.data(forKey: remindersKey) else {
            return []
        }
        return try JSONDecoder().decode([ReminderModel].self, from: data)
    }
}