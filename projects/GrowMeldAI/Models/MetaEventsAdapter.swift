final class MetaEventsAdapter {
    private class EventRecord {
        let event: DriveAIEvent
        let timestamp: Date
        
        func isExpired(window: TimeInterval) -> Bool {
            Date().timeIntervalSince(timestamp) > window
        }
    }
    
    private let batchQueue = DispatchQueue(
        label: "com.driveai.batch",
        qos: .utility,
        attributes: .concurrent
    )
    private var pendingBatch: [DriveAIEvent] = []
    private var batchTimer: Timer?
    private let batchSize = 10
    private let maxWaitSeconds = 30.0
    
    init(metaAdsService: MetaAdsServiceProtocol) {
        self.metaAdsService = metaAdsService
        setupLifecycleObservers()
    }
    
    func track(_ event: DriveAIEvent) {
        batchQueue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            
            self.pendingBatch.append(event)
            
            // Start timer on first event
            if self.pendingBatch.count == 1 {
                self.startBatchTimer()
            }
            
            // Send if batch full
            if self.pendingBatch.count >= self.batchSize {
                self.flushBatch()
            }
        }
    }
    
    private func startBatchTimer() {
        batchTimer?.invalidate()
        batchTimer = Timer.scheduledTimer(
            withTimeInterval: maxWaitSeconds,
            repeats: false
        ) { [weak self] _ in
            self?.batchQueue.async(flags: .barrier) {
                self?.flushBatch()
            }
        }
    }
    
    private func flushBatch() {
        guard !pendingBatch.isEmpty else { return }
        
        let batch = pendingBatch
        pendingBatch.removeAll()
        batchTimer?.invalidate()
        
        // Send asynchronously (non-blocking)
        Task {
            do {
                try await sendToMeta(batch: batch)
            } catch {
                // Persist for retry
                self.persistFailedBatch(batch)
            }
        }
    }
    
    private func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(flushOnBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc private func flushOnBackground() {
        batchQueue.async(flags: .barrier) { [weak self] in
            self?.flushBatch()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}