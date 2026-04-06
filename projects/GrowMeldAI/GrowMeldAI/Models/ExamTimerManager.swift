@MainActor
final class ExamTimerManager: NSObject, ObservableObject {
    @Published var remainingSeconds: Int = 1800  // 30 min
    
    private var timer: Timer?
    private var pausedAt: Date?
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.remainingSeconds -= 1
            if self?.remainingSeconds ?? 0 <= 0 {
                self?.stopTimer()
            }
        }
        
        // Subscribe to app state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func appWillResignActive() {
        pausedAt = .now
        timer?.invalidate()
    }
    
    @objc private func appDidBecomeActive() {
        // Calculate elapsed time during background
        if let paused = pausedAt {
            let elapsed = Int(Date().timeIntervalSince(paused))
            remainingSeconds = max(0, remainingSeconds - elapsed)
        }
        startTimer()
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        NotificationCenter.default.removeObserver(self)
    }
}