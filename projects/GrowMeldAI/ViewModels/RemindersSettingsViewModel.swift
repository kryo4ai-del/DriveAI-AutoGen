@MainActor
final class RemindersSettingsViewModel: ObservableObject {
    @Published var configuration: ReminderConfiguration
    @Published var reminderTime: Date
    @Published var frequency: ReminderFrequency
    @Published var isEnabled: Bool
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Injected dependencies
    private let scheduler: ReminderScheduler
    private let persistence: ReminderPersistenceService
    private let notificationCenter: UNUserNotificationCenter
    
    // User actions
    func toggleReminders() async
    func updateTime(_ date: Date) async
    func updateFrequency(_ freq: ReminderFrequency) async
    func saveChanges() async
    func requestNotificationPermission() async
}