// Core/Services/TimerService.swift
import Foundation
import UIKit
import os.log

final class TimerService: ObservableObject {
    @Published private(set) var secondsRemaining: Int = 0
    @Published private(set) var isExpired: Bool = false
    @Published private(set) var isRunning: Bool = false

    private var timer: Timer?
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    private var sessionStartTime: Date?
    private var pausedTime: TimeInterval = 0
    private let logger = Logger(subsystem: "com.driveai", category: "TimerService")

    deinit {
        stopTimer()
        endBackgroundTask()
    }

    func start(durationSeconds: Int) {
        stopTimer()
        endBackgroundTask()

        secondsRemaining = max(0, durationSeconds)
        isExpired = false
        isRunning = true
        sessionStartTime = Date()

        logger.info("Timer started: \(durationSeconds) seconds")

        // Start background task
        beginBackgroundTask()

        // Start timer
        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }
    }

    func pause() {
        guard isRunning else { return }
        stopTimer()
        pausedTime = Date().timeIntervalSince(sessionStartTime ?? Date())
        logger.info("Timer paused at \(pausedTime) seconds")
    }

    func resume() {
        guard !isRunning, secondsRemaining > 0 else { return }

        sessionStartTime = Date().addingTimeInterval(-pausedTime)
        isRunning = true

        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }

        logger.info("Timer resumed")
    }

    func stop() {
        stopTimer()
        endBackgroundTask()
        secondsRemaining = 0
        isExpired = false
        isRunning = false
        sessionStartTime = nil
        logger.info("Timer stopped")
    }

    func appDidEnterBackground() {
        guard isRunning else { return }
        beginBackgroundTask()
    }

    func appWillEnterForeground() {
        endBackgroundTask()
    }

    private func beginBackgroundTask() {
        endBackgroundTask() // End any existing task

        backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }

        logger.info("Background task started: \(backgroundTaskId)")
    }

    private func endBackgroundTask() {
        if backgroundTaskId != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
            backgroundTaskId = .invalid
            logger.info("Background task ended")
        }
    }

    private func tick() {
        guard isRunning, secondsRemaining > 0 else {
            if secondsRemaining <= 0 {
                handleExpired()
            }
            return
        }

        secondsRemaining -= 1

        if secondsRemaining <= 0 {
            handleExpired()
        }
    }

    private func handleExpired() {
        stopTimer()
        isExpired = true
        isRunning = false
        logger.info("Timer expired")
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}