import Foundation

enum ExamReadinessTier: Equatable {
    case needsWork(questionsRemaining: Int)
    case makingProgress(confidenceLevel: String)
    case almostReady(daysUntilExam: Int)
    case ready
}

enum TemporalZone {
    case earlyStage      // 90+ days
    case buildingPhase   // 30-90 days
    case finalPush       // 7-30 days
    case lastMinute      // <7 days
}

// Struct ExamReadinessAssessment declared in Models/UserDiagnosticProfile.swift
