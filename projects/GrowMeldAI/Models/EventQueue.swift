@MainActor
final class EventQueue: Sendable {
    private let retryScheduler: RetryScheduler
    
    func setupAutoFlush() {
        // Flush on network state change
        NotificationCenter.default.addObserver(
            forName: .reachabilityDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.flushQueue()
            }
        }
        
        // Flush on app background -> foreground
        let foregroundNotification = UIApplication.didBecomeActiveNotification
        NotificationCenter.default.addObserver(
            forName: foregroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.flushQueue()
            }
        }
    }
    
    func flushQueue() async {
        while !eventQueue.isEmpty {
            let event = eventQueue[0]
            
            do {
                try await Analytics.send(event)
                eventQueue.removeFirst()
                try saveToDisk()
            } catch {
                // Exponential backoff retry
                try await retryScheduler.scheduleRetry(event)
                break  // Stop processing, try again later
            }
        }
    }
}