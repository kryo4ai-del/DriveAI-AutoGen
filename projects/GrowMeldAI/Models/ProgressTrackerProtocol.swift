// Services/Domain/ProgressTracker.swift
import Foundation

protocol ProgressTrackerProtocol {
    func updateProgress(from result: ExamResult, profile: inout UserProfile)
    func calculateStreak(lastActivityDate: Date?, currentDate: Date) -> Int
    func calculateCategoryStats(progress: CategoryProgress) -> CategoryStats
    func resetProgress(profile: inout UserProfile)
}

// MARK: - Supporting Models
