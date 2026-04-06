// Services/TimerService/CountdownTimerService.swift
import Foundation

class CountdownTimerService: ObservableObject {
    @Published var secondsRemaining: Int = 0
    @Published var isRunning: Bool = false
    
    private var timer: Timer?
    private var totalSeconds: Int = 0
    
    func startTimer(seconds: Int) {
        self.totalSeconds = seconds
        self.secondsRemaining = seconds
        self.isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
    }
    
    func resumeTimer() {
        guard !isRunning else { return }
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        secondsRemaining = 0
    }
    
    private func tick() {
        secondsRemaining -= 1
        
        if secondsRemaining <= 0 {
            stopTimer()
        }
    }
    
    func formatTime() -> String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    deinit {
        timer?.invalidate()
    }
}