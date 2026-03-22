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