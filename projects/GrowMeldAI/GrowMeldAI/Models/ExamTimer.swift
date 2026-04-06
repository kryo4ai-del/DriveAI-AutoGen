@MainActor
final class ExamTimer: NSObject, ObservableObject {
    @Published var remainingSeconds: Int = 1800
    @Published var isRunning: Bool = false
    @Published var didTimeOut: Bool = false
    
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.driveai.timer", qos: .userInteractive)
    private var startTime: Date?
    
    func start(duration: Int = 1800) {
        remainingSeconds = duration
        startTime = Date()
        isRunning = true
        didTimeOut = false
        
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(wallDeadline: .now(), repeating: 1.0, leeway: .milliseconds(100))
        
        timer.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.tick()
            }
        }
        
        timer.resume()
        self.timer = timer
    }
    
    func pause() {
        isRunning = false
        timer?.suspend()
    }
    
    func resume() {
        isRunning = true
        timer?.resume()
    }
    
    func stop() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    private func tick() {
        remainingSeconds -= 1
        
        if remainingSeconds <= 0 {
            didTimeOut = true
            stop()
        }
    }
}