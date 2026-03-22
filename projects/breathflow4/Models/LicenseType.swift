import Foundation
import SwiftUI

// MARK: - Enums

enum LicenseType: String, Codable, CaseIterable {
    case carB = "Car (Category B)"
    case motorcycle = "Motorcycle"
    case heavyVehicle = "Heavy Vehicle"
    
    var displayName: String { self.rawValue }
    var emoji: String {
        switch self {
        case .carB: return "🚗"
        case .motorcycle: return "🏍️"
        case .heavyVehicle: return "🚚"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable, Comparable {
    case beginner, intermediate, advanced
    
    var displayName: String { self.rawValue.capitalized }
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
    
    static func < (lhs: Difficulty, rhs: Difficulty) -> Bool {
        let order: [Difficulty] = [.beginner, .intermediate, .advanced]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

enum TopicArea: String, Codable, CaseIterable {
    case trafficSigns = "Traffic Signs"
    case rules = "Road Rules"
    case hazardPerception = "Hazard Perception"
    case parkingManeuvers = "Parking Maneuvers"
    
    var displayName: String { self.rawValue }
}

// MARK: - Data Models

enum QuestionError: LocalizedError {
    case emptyText
    case invalidOptionCount(Int)
    case invalidCorrectAnswerIndex
    
    var errorDescription: String? {
        switch self {
        case .emptyText: return "Question text cannot be empty"
        case .invalidOptionCount(let count): return "Expected 4 options, got \(count)"
        case .invalidCorrectAnswerIndex: return "Correct answer index is out of bounds"
        }
    }
}

enum QuizError: LocalizedError {
    case noQuestions
    case questionQuizMismatch(questionId: UUID)
    
    var errorDescription: String? {
        switch self {
        case .noQuestions: return "Quiz must contain at least one question"
        case .questionQuizMismatch: return "Question references incorrect quiz"
        }
    }
}

struct UserAnswer: Identifiable, Codable {
    let id: UUID
    let questionId: UUID
    let selectedIndex: Int
    let isCorrect: Bool
    let timeSpentSeconds: TimeInterval
}

enum AttemptError: LocalizedError {
    case invalidScore
    case scoreOutOfBounds
    
    var errorDescription: String? {
        switch self {
        case .invalidScore: return "Correct answers cannot exceed total questions"
        case .scoreOutOfBounds: return "Score must be between 0 and 100"
        }
    }
}

struct QuizProgress: Identifiable, Codable {
    let id: UUID
    let quizId: UUID
    private(set) var attempts: [QuizAttempt]
    
    var bestScore: Double {
        attempts.map(\.score).max() ?? 0
    }
    
    var completionCount: Int {
        attempts.count
    }
    
    var lastAttemptDate: Date? {
        attempts.max(by: { $0.completedAt < $1.completedAt })?.completedAt
    }
    
    var shouldReview: Bool {
        // Review if score < 85% OR not attempted in 7 days
        guard let lastDate = lastAttemptDate else { return true }
        let daysSinceLast = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        return bestScore < 85 || daysSinceLast > 7
    }
    
    mutating func addAttempt(_ attempt: QuizAttempt) throws {
        try attempt.validate()
        attempts.append(attempt)
    }
}