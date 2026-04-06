// Pattern for ALL ViewModels with timers:

@MainActor
class TimerViewModelExample: ObservableObject {
    private var timer: Timer?
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil  // ✅ FIX: Explicitly nil out
    }
    
    deinit {
        stopTimer()  // ✅ FIX: Always cleanup
    }
}