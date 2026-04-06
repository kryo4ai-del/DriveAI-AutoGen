struct SyncPolicy: Equatable {
    let priority: SyncPriority
    let maxRetries: Int
    let backoffStrategy: BackoffStrategy
    let timeoutSeconds: Int
    let allowOfflineQueueing: Bool
    
    init(
        priority: SyncPriority,
        maxRetries: Int,
        backoffStrategy: BackoffStrategy,
        timeoutSeconds: Int,
        allowOfflineQueueing: Bool
    ) throws {
        guard maxRetries > 0 else {
            throw ResilienceError.offline(.corruptedCache)
        }
        guard timeoutSeconds > 0 else {
            throw ResilienceError.offline(.corruptedCache)
        }
        
        self.priority = priority
        self.maxRetries = maxRetries
        self.backoffStrategy = backoffStrategy
        self.timeoutSeconds = timeoutSeconds
        self.allowOfflineQueueing = allowOfflineQueueing
    }
}