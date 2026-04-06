final class LocalReminderService: ReminderService {  // No @MainActor
    private let remindersQueue = DispatchQueue(label: "com.driveai.reminders", attributes: .concurrent)
    
    func createReminder(...) async throws -> Reminder {
        let reminder = Reminder(...)
        
        try remindersQueue.sync(flags: .barrier) {
            reminders.append(reminder)
            try persistReminders()
        }
        
        if preferences.allowNotifications {
            try await scheduleReminder(reminder)
        }
        return reminder
    }
}