import Foundation
import Combine
// Features/ExamReadiness/Services/ExamTimerService.swift
@MainActor
final class ExamTimerService {
    @Published var timeRemaining: Int = 0
    
    private var timer: Timer?
    private let sessionStartTime: Date
    private let examDurationSeconds: Int
    
    init(sessionStartTime: Date, durationMinutes: Int = 60) {
        self.sessionStartTime = sessionStartTime
        self.examDurationSeconds = durationMinutes * 60
        self.timeRemaining = examDurationSeconds
    }
    
    var hasTimeExpired: Bool {
        timeRemaining == 0
    }
    
    var displayTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func start(onExpired: @escaping () -> Void) {
        // Stop any existing timer
        stop()
        
        // Recover elapsed time from session start
        let elapsed = Int(Date().timeIntervalSince(sessionStartTime))
        timeRemaining = max(0, examDurationSeconds - elapsed)
        
        // Fire immediately if time already expired
        guard timeRemaining > 0 else {
            onExpired()
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining = max(0, self.timeRemaining - 1)
            
            if self.timeRemaining == 0 {
                self.stop()
                onExpired()
            }
        }
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
    }
    
    func resume(onExpired: @escaping () -> Void) {
        start(onExpired: onExpired)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stop()
    }
}