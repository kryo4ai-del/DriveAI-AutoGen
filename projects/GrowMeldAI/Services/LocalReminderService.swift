final class LocalReminderService: ReminderService {
    private let remindersQueue = DispatchQueue(label: "com.driveai.reminders", attributes: .concurrent)
    private var reminders: [Reminder] = []
    private var preferences = Preferences()

    func createReminder(title: String, date: Date) async throws -> Reminder {
        let reminder = Reminder(title: title, date: date)

        try remindersQueue.sync(flags: .barrier) {
            reminders.append(reminder)
            try persistReminders()
        }

        if preferences.allowNotifications {
            try await scheduleReminder(reminder)
        }
        return reminder
    }

    private func persistReminders() throws {
    }

    private func scheduleReminder(_ reminder: Reminder) async throws {
    }
}