@MainActor
final class ExamSimulatorViewModel: ObservableObject {
    @Published var timeRemaining: Int = 1800  // 30 minutes
    @Published var isPaused = false
    
    private var timerTask: Task<Void, Never>?
    private let dataService: LocalDataService
    
    init(dataService: LocalDataService) {
        self.dataService = dataService
    }
    
    func startExam() {
        // ✅ Cancel any existing timer
        timerTask?.cancel()
        
        // ✅ Use Task<>-based timer (respects cancellation)
        timerTask = Task {
            while !Task.isCancelled && timeRemaining > 0 && !isPaused {
                try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
                
                if !Task.isCancelled {
                    timeRemaining -= 1
                    
                    // Warning at 5 minutes
                    if timeRemaining == 300 {
                        hapticWarning()
                    }
                    
                    // Auto-submit at 0
                    if timeRemaining == 0 {
                        await submitExam()
                    }
                }
            }
        }
    }
    
    func pauseExam() {
        isPaused = true
        timerTask?.cancel()
        timerTask = nil
    }
    
    func resumeExam() {
        isPaused = false
        startExam()  // Restart timer
    }
    
    func exitExam() {
        timerTask?.cancel()
        timerTask = nil
        // Save state to disk for recovery
    }
    
    // ✅ Critical: Clean up on dealloc
    deinit {
        timerTask?.cancel()
    }
    
    private func hapticWarning() {
        let impact = UIImpactFeedbackGenerator(style: .warning)
        impact.impactOccurred()
    }
}