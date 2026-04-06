// CloudFunctionsService.swift
import Foundation
import Combine

// MARK: - Domain Models
struct QuestionAnswer: Codable, Equatable {
    let questionId: String
    let selectedOptionId: String
    let timeSpentSeconds: Int
    let isFlagged: Bool
}

struct QuestionExplanation: Codable, Equatable {
    let questionId: String
    let correctOptionId: String
    let rationale: String
    let ruleReference: String
}

struct QuestionOption: Codable, Equatable {
    let id: String
    let text: String
}

// MARK: - Service Protocol
protocol CloudFunctionsServicing: AnyObject {
    func gradeExamWithSpacedRepetition(_ answers: [QuestionAnswer]) async throws -> ExamResult
    func unlockNextLearningPath() async throws -> [Question]
    func reconcileKnowledgeGaps() async throws -> UserProgress
    func getUserStatistics() async throws -> UserProgress
}

// MARK: - Service Implementation

// MARK: - Error Types
enum CloudFunctionError: Error, Equatable {
    case invalidInput(String)
    case invalidResponse
    case networkUnavailable
    case timeout
    case serverError(String, Int)
    case networkError(URLError)
    case unknownError(Error)

    var localizedDescription: String {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .invalidResponse:
            return "Invalid server response"
        case .networkUnavailable:
            return "No internet connection available"
        case .timeout:
            return "Request timed out"
        case .serverError(let message, _):
            return "Server error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

private struct CloudFunctionErrorResponse: Codable {
    let message: String
    let code: String?
    let details: [String: String]?
}