struct RemindersSettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        List(notificationManager.reminders) { reminder in
            HStack {
                Text("\(reminder.scheduledTime.formatted(date: .omitted, time: .shortened))")
                Spacer()
                Toggle("", isOn: Binding(
                    get: { reminder.isEnabled },
                    set: { _ in
                        Task {
                            await notificationManager.toggleReminder(id: reminder.id)
                        }
                    }
                ))
            }
        }
    }
}