// StateManager.swift
import Foundation
import SwiftUI
import Combine

/// Thread-safe state management for DriveAI app
final class DriveAIStateManager: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: DriveAIError?
    @Published private(set) var userProgress: UserProgress = UserProgress()

    private let queue = DispatchQueue(label: "com.driveai.stateManager", qos: .userInitiated)
    private var cancellables = Set<AnyCancellable>()

    // Exam readiness calculation
    var examReadiness: ExamReadiness {
        calculateExamReadiness()
    }

    // Thread-safe access to user progress
    func updateProgress(_ progress: UserProgress) {
        queue.async { [weak self] in
            self?.userProgress = progress
        }
    }

    func setLoading(_ isLoading: Bool) {
        queue.async { [weak self] in
            self?.isLoading = isLoading
        }
    }

    func setError(_ error: DriveAIError?) {
        queue.async { [weak self] in
            self?.error = error
        }
    }

    func clearError() {
        queue.async { [weak self] in
            self?.error = nil
        }
    }

    private func calculateExamReadiness() -> ExamReadiness {
        // Simple calculation for demonstration
        // In production, this would use actual user data and a more sophisticated algorithm
        let totalQuestions = 1000 // Example total
        let correctAnswers = userProgress.correctAnswers
        let totalAttempts = userProgress.totalAttempts

        guard totalAttempts > 0 else {
            return ExamReadiness(score: 0, narrative: String(localized: "Beginne mit den Fragen, um deine Bereitschaft zu sehen.", comment: "Default readiness narrative"))
        }

        let accuracy = Double(correctAnswers) / Double(totalAttempts)
        let recencyFactor = min(1.0, Double(userProgress.lastActivityDaysAgo) / 30.0) // Normalize to 30 days
        let readinessScore = min(1.0, accuracy * (1.0 - recencyFactor * 0.5)) * 100

        let narrative: String
        if readinessScore >= 90 {
            narrative = String(localized: "Fantastisch! Du bist zu \(Int(readinessScore))% bereit für deine Prüfung am \(userProgress.examDate.formatted(.dateTime.day().month())).", comment: "High readiness narrative")
        } else if readinessScore >= 75 {
            narrative = String(localized: "Gut gemacht! Du bist zu \(Int(readinessScore))% bereit. Noch \(Int(100 - readinessScore))% Unsicherheit — lass uns die letzten Lücken schließen.", comment: "Medium readiness narrative")
        } else {
            narrative = String(localized: "Du bist zu \(Int(readinessScore))% bereit. Mit etwas mehr Übung wirst du sicher für deine Prüfung am \(userProgress.examDate.formatted(.dateTime.day().month())).", comment: "Low readiness narrative")
        }

        return ExamReadiness(score: Int(readinessScore), narrative: narrative)
    }
}

/// User progress tracking model

/// Exam readiness model
struct ExamReadiness {
    let score: Int
    let narrative: String
}