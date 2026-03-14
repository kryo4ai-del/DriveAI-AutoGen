// Models/ExamReadiness.swift
import Foundation

struct ExamReadiness {
    let categoryScores: [String: CategoryReadiness]
    let overallReadinessScore: Double // 0.0–1.0
    let recommendedFocusCategories: [String] // sorted by weakness
    let predictedPassProbability: Double // 0.0–1.0
    let minimumStudyHoursRemaining: Int
    
    var isRecommendedForExam: Bool {
        overallReadinessScore >= 0.75 && predictedPassProbability >= 0.80
    }
}

struct CategoryReadiness {
    let categoryID: String
    let categoryName: String
    let correctAnswerPercentage: Double // 0.0–1.0
    let questionsAnswered: Int
    let questionsCorrect: Int
    let readinessLevel: ReadinessLevel
    
    enum ReadinessLevel: Equatable {
        case notStarted
        case beginner      // 0–40%
        case intermediate  // 40–70%
        case advanced      // 70–90%
        case mastered      // 90%+
        
        var label: String {
            switch self {
            case .notStarted: return "Not Started"
            case .beginner: return "Beginner (0–40%)"
            case .intermediate: return "Intermediate (40–70%)"
            case .advanced: return "Advanced (70–90%)"
            case .mastered: return "Mastered (90%+)"
            }
        }
        
        var color: Color {
            switch self {
            case .notStarted: return .gray
            case .beginner: return .red
            case .intermediate: return .orange
            case .advanced: return .yellow
            case .mastered: return .green
            }
        }
    }
    
    var isReadyForExam: Bool {
        correctAnswerPercentage >= 0.75
    }
}