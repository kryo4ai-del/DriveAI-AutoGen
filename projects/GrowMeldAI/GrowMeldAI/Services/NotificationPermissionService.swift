@MainActor
class NotificationPermissionService {
    func requestAuthorization(for types: Set<NotificationType> = .allTypes) async throws {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        let granted = try await UNUserNotificationCenter.current()
            .requestAuthorization(options: options)
        
        // ❌ System prompt shown here, but no custom accessible UI designed
        // ❌ Users with disabilities see generic "Allow notifications?" dialog
        // ❌ No explanation of which types of notifications will be sent
    }
}