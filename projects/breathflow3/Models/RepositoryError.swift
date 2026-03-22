// Models/RepositoryError.swift
import Foundation

enum RepositoryError: LocalizedError {
    case networkUnavailable
    case invalidResponse
    case decodingError(String)
    case serverError(Int)
    case timeout

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network is unavailable"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .timeout:
            return "Request timed out"
        }
    }
}
