// ViewModels/ExamSimulation/ExamSimulationViewModel.swift
import SwiftUI

/// Constants for exam simulation.
struct ExamConstants {
    static let questionCount = 30
    static let passingScoreThreshold = 26  // 43/50 (86%) scaled to 30 questions
    static let examDurationSeconds: TimeInterval = 1800  // 30 minutes
}

// Class ExamSimulationViewModel declared in Models/ExamState.swift
