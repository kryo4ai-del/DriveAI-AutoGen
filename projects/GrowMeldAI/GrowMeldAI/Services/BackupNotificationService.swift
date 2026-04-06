class BackupNotificationService {
    func showSuccessMessage(_ message: String) async
    func sendStaleBackupNotification() async throws
    func requestNotificationPermission() async -> Bool
}