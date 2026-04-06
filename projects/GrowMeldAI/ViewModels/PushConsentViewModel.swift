@MainActor
class PushConsentViewModel {
    private func scheduleReminders() async {
        // This runs on MainActor
        try await pushService.scheduleQuizReminderNotification(...)
    }
}