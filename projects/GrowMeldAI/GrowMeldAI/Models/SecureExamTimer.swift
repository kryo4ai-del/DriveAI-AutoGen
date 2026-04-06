// ✅ RESILIENT TIMER WITH FRAUD DETECTION
final class SecureExamTimer {
    enum TimerError: LocalizedError {
        case systemTimeManipulation
        case timerCorrupted
        
        var errorDescription: String? {
            switch self {
            case .systemTimeManipulation:
                return "Systemzeit wurde geändert. Prüfung annulliert."
            case .timerCorrupted:
                return "Timer-Fehler. Prüfung wird beendet."
            }
        }
    }
    
    private let startDate: Date
    private let durationSeconds: Int
    private let backgroundTaskManager: BackgroundTaskManager
    
    private var pausedTime: TimeInterval = 0
    private var lastRecordedDate: Date
    private var timeAnomalies: [TimeAnomaly] = []
    
    init(durationSeconds: Int) {
        self.durationSeconds = durationSeconds
        self.startDate = Date()
        self.lastRecordedDate = Date()
        self.backgroundTaskManager = BackgroundTaskManager.shared
        
        setupBackgroundHandling()
    }
    
    // MARK: - Public Interface
    func getRemainingSeconds() throws -> Int {
        let now = Date()
        
        // Detect system time manipulation (clock backwards)
        if now < lastRecordedDate {
            let anomaly = TimeAnomaly(
                detectedAt: Date(),
                type: .clockManipulation,
                deviation: lastRecordedDate.timeIntervalSince(now)
            )
            timeAnomalies.append(anomaly)
            
            if timeAnomalies.filter({ $0.type == .clockManipulation }).count >= 2 {
                throw TimerError.systemTimeManipulation
            }
        }
        
        lastRecordedDate = now
        
        // Calculate actual elapsed time (not dependent on Timer callback)
        let elapsedTime = now.timeIntervalSince(startDate) - pausedTime
        let remaining = max(0, durationSeconds - Int(elapsedTime))
        
        return remaining
    }
    
    func pause() {
        // Called when app backgrounds
        pauseStartTime = Date()
    }
    
    func resume() throws {
        // Called when app foregrounds
        let pauseDuration = Date().timeIntervalSince(pauseStartTime)
        pausedTime += pauseDuration
        
        // Detect suspicious pause durations
        if pauseDuration > 300 { // > 5 minutes
            let anomaly = TimeAnomaly(
                detectedAt: Date(),
                type: .suspiciousPause,
                deviation: pauseDuration
            )
            timeAnomalies.append(anomaly)
        }
    }
    
    func getAuditTrail() -> TimerAuditTrail {
        return TimerAuditTrail(
            startDate: startDate,
            anomalies: timeAnomalies,
            isSuspicious: timeAnomalies.count >= 2
        )
    }
    
    // MARK: - Private
    private var pauseStartTime = Date()
    
    private func setupBackgroundHandling() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.pause()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            try? self?.resume()
        }
    }
}

struct TimeAnomaly: Codable {
    let detectedAt: Date
    let type: AnomalyType
    let deviation: TimeInterval // seconds
    
    enum AnomalyType: String, Codable {
        case clockManipulation
        case suspiciousPause
        case timerDrift
    }
}

struct TimerAuditTrail: Codable {
    let startDate: Date
    let anomalies: [TimeAnomaly]
    let isSuspicious: Bool
    
    func reportToServer() async throws {
        // For future backend: POST anomalies for exam integrity review
    }
}