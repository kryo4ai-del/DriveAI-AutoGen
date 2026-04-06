@MainActor
class NotificationPermissionViewModel: ObservableObject {
    @Published var status: UNAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var error: NotificationError?
    
    private let service: NotificationPermissionService
    
    func requestPermission() async {
        isLoading = true
        do {
            try await service.requestAuthorization()
            status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        } catch {
            self.error = error as? NotificationError
        }
        isLoading = false
    }
    
    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
}