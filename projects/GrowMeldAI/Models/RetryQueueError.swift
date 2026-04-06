// ✅ BOUNDED QUEUE
private let maxQueueSize = 100

func enqueue(_ request: PendingRequest) throws {
    guard pendingRequests.count < maxQueueSize else {
        throw RetryQueueError.queueFull
    }
    
    var mutableRequest = request
    mutableRequest.retryCount = 0
    pendingRequests.append(mutableRequest)
    persistQueue()
}

enum RetryQueueError: LocalizedError {
    case queueFull
    
    var errorDescription: String? {
        return "Retry queue is full. Please check your network connection."
    }
}