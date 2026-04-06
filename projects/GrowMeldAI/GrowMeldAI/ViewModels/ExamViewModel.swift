class ExamViewModel: ObservableObject {
    @Published var isExamActive = false
    @Published var timeRemainingSeconds = 30 * 60
    
    private var timerTask: Task<Void, Never>?
    private let examDurationSeconds = 30 * 60
    
    func startExam() {
        guard !isExamActive else {
            print("⚠️ Exam already started")
            return  // ✅ Guard: prevent double-start
        }
        isExamActive = true
        startTimer()
    }
    
    private func startTimer() {
        timerTask?.cancel()  // ✅ Cancel any existing timer
        
        timerTask = Task {
            while !Task.isCancelled && isExamActive && timeRemainingSeconds > 0 {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
                    
                    DispatchQueue.main.async {
                        self.timeRemainingSeconds -= 1
                        if self.timeRemainingSeconds == 0 {
                            self.finishExam()
                        }
                    }
                } catch {
                    break  // Task cancelled
                }
            }
        }
    }
    
    func pauseExam() {
        isExamActive = false
        timerTask?.cancel()
    }
    
    func finishExam() {
        isExamActive = false
        timerTask?.cancel()
        // Compute result...
    }
    
    deinit {
        timerTask?.cancel()  // ✅ Clean up on deallocation
    }
}

// Test
func testStartExamTwiceDoesNotCreateDuplicateTimers() {
    let viewModel = ExamViewModel()
    viewModel.startExam()
    let initialTask = viewModel.timerTask
    
    viewModel.startExam()  // Second call should be ignored
    XCTAssertEqual(viewModel.timerTask, initialTask, "Timer should not be recreated")
}