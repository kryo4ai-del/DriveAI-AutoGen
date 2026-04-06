class NotificationRegistrationService {
    private let maxRetries = 3
    private var retryCount = 0
    
    func registerForRemoteNotifications() async throws {
        do {
            try await Messaging.messaging().getToken()
            retryCount = 0 // Reset on success
        } catch {
            guard retryCount < maxRetries else {
                throw NotificationError.registrationFailedAfterRetries
            }
            
            retryCount += 1
            try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
            try await registerForRemoteNotifications() // Exponential backoff
        }
    }
}
