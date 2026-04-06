// Utils/TimerManager.swift
class TimerManager: ObservableObject {
    @Published var timeRemaining: Int
    @Published var isRunning = false
    
    private var timer: Timer?
    private let duration: Int
    private var onTick: (() -> Void)?
    private var onExpire: (() -> Void)?
    
    init(duration: Int) {
        self.duration = duration
        self.timeRemaining = duration
    }
    
    func start(onTick: @escaping () -> Void = {}, onExpire: @escaping () -> Void = {}) {
        self.onTick = onTick
        self.onExpire = onExpire
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        timeRemaining -= 1
        onTick?()
        
        if timeRemaining <= 0 {
            stop()
            onExpire?()
        }
    }
    
    func stop() {
        timer?.invalidate()
        isRunning = false
    }
    
    func reset() {
        stop()
        timeRemaining = duration
    }
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var isWarning: Bool {
        timeRemaining < 300
    }
    
    deinit {
        stop()
    }
}

// Usage in ExamSimulationViewModel