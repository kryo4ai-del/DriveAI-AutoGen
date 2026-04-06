// ViewModels/Reminders/ReminderViewModel.swift

@MainActor
final class ReminderViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var preferences: ReminderPreferences = .init()
    @Published var showReminderPrompt = false
    @Published var pendingTrigger: ReminderTrigger?
    
    private let reminderService: ReminderService
    
    init(reminderService: ReminderService) {
        self.reminderService = reminderService
        self.reminders = reminderService.reminders
        self.preferences = reminderService.preferences
    }
    
    func triggerReminder(for trigger: ReminderTrigger) async {
        pendingTrigger = trigger
        showReminderPrompt = true
    }
    
    func acceptReminder() async throws {
        guard let trigger = pendingTrigger else { return }
        let action = actionFor(trigger: trigger)
        try await reminderService.createReminder(trigger, action: action)
        try await reminderService.scheduleReminder(/* ... */)
    }
}