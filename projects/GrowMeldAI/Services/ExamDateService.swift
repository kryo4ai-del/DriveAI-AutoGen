@MainActor
final class ExamDateService: ObservableObject {
    // ... 
    private var updateTimer: Timer?
    
    init() {
        loadExamDate()
        updateDaysRemaining()
        startUpdateTimer()
    }
    
    private func startUpdateTimer() {
        // Update at midnight
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateDaysRemaining()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}