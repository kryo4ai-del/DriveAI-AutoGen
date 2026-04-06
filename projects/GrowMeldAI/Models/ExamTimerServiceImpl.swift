final class ExamTimerServiceImpl: ExamTimerService {
    private var timer: Timer?
    private var onFinish: (() -> Void)?
    
    deinit {
        stop()  // ✅ Always invalidate on dealloc
    }
    
    func start(duration: Int, onTick: @escaping (Int) -> Void, onFinish: @escaping () -> Void) {
        stop()  // ✅ Stop any existing timer first
        
        timeRemaining = duration
        self.onTick = onTick
        self.onFinish = onFinish
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.tick()
        }
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        onFinish = nil  // ✅ Break reference cycle
        onTick = nil
    }
}