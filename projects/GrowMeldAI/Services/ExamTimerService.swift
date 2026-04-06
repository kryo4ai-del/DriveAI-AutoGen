// Core/Services/ExamTimerService.swift
import Foundation
import UIKit

@MainActor
final class ExamTimerService: ObservableObject {
    @Published var secondsRemaining: Int = 0
    @Published var isExpired: Bool = false
    
    private var timer: Timer?
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    private var sessionStartTime: Date?
    private var pausedTime: TimeInterval = 0
    private let logger = Logger(category: "ExamTimerService")
    
    // MARK: - Lifecycle
    
    deinit {
        stop()
    }
    
    // MARK: - Public API
    
    func start(durationSeconds: Int) {
        secondsRemaining = durationSeconds
        sessionStartTime = Date()
        isExpired = false
        
        // Register background task (gives 10 minutes to finish)
        backgroundTaskId = UIApplication.shared.beginBackgroundTask(
            withName: "com.driveai.exam-timer",
            expirationHandler: { [weak self] in
                self?.logger.warning("⏰ Background task expiring")
                self?.endBackgroundTask()
            }
        )
        
        // Start countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        logger.info("⏱️ Exam timer started: \(durationSeconds)s")
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
        pausedTime = Date().timeIntervalSince(sessionStartTime ?? Date())
        logger.info("⏸️ Timer paused")
    }
    
    func resume() {
        sessionStartTime = Date().addingTimeInterval(-pausedTime)
        start(durationSeconds: secondsRemaining)
        logger.info("▶️ Timer resumed")
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        endBackgroundTask()
        logger.info("⏹️ Timer stopped")
    }
    
    // MARK: - App Lifecycle Handlers
    
    func appDidEnterBackground() {
        logger.debug("📱 App backgrounded, timer paused")
        pause()
    }
    
    func appWillEnterForeground() {
        guard secondsRemaining > 0 && !isExpired else { return }
        
        // Recalculate time to account for background duration
        let elapsedInBackground = Date().timeIntervalSince(sessionStartTime ?? Date())
        let calculatedRemaining = Int(TimeInterval(secondsRemaining) - elapsedInBackground)
        
        if calculatedRemaining > 0 {
            secondsRemaining = calculatedRemaining
            resume()
            logger.info("📱 App resumed, \(calculatedRemaining)s remaining")
        } else {
            // Time expired while in background
            secondsRemaining = 0
            handleExpired()
        }
    }
    
    // MARK: - Private
    
    private func tick() {
        secondsRemaining -= 1
        
        if secondsRemaining <= 0 {
            handleExpired()
        } else if secondsRemaining == 300 {
            // 5 min warning
            NotificationCenter.default.post(name: NSNotification.Name("ExamTimer.FiveMinuteWarning"))
        } else if secondsRemaining == 60 {
            // 1 min warning
            NotificationCenter.default.post(name: NSNotification.Name("ExamTimer.OneMinuteWarning"))
        }
    }
    
    private func handleExpired() {
        timer?.invalidate()
        timer = nil
        secondsRemaining = 0
        isExpired = true
        
        NotificationCenter.default.post(name: NSNotification.Name("ExamTimer.Expired"))
        logger.warning("⏰ Exam time expired")
        endBackgroundTask()
    }
    
    private func endBackgroundTask() {
        guard backgroundTaskId != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTaskId)
        backgroundTaskId = .invalid
    }
}

// MARK: - Scene Delegate Integration
