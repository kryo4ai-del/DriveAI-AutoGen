// DriveAI/Data/Network/APIModels.swift
import Foundation

// API Response DTOs (separate from domain models)
struct APIQuestionsResponse: Codable {
    let questions: [APIQuestion]
    let totalCount: Int
    let page: Int
    let hasMore: Bool
}

struct APIQuestion: Codable {
    let id: String
    let text: String
    let categoryId: String
    let imageUrl: String?
    let answers: [APIAnswer]
    let correctAnswerId: String
    let explanation: String?
    let difficulty: String
    let version: Int
    let updatedAt: String
}

struct APIAnswer: Codable {
    let id: String
    let text: String
    let imageUrl: String?
}

struct APICategory: Codable {
    let id: String
    let name: String
    let description: String?
    let questionCount: Int
    let order: Int
}

struct APISyncRequest: Codable {
    let lastSyncedAt: Date?
}

struct APISyncResponse: Codable {
    let questions: [APIQuestion]
    let categories: [APICategory]
    let deletedQuestionIds: [String]
    let syncedAt: String
}

enum PlantIdAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimited
    case serverError(statusCode: Int)
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return NSLocalizedString("network_error_unavailable", comment: "Network unavailable")
        case .rateLimited:
            return NSLocalizedString("network_error_rate_limited", comment: "Too many requests")
        case .unauthorized:
            return NSLocalizedString("network_error_unauthorized", comment: "Authentication failed")
        default:
            return NSLocalizedString("network_error_generic", comment: "Request failed")
        }
    }
}