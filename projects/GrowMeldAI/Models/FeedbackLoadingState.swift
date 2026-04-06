import Foundation

enum FeedbackLoadingState<T: Equatable>: Equatable {
    case idle
    case loading
    case success(T)
    case failure(FeedbackError)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var error: FeedbackError? {
        if case .failure(let error) = self { return error }
        return nil
    }

    var value: T? {
        if case .success(let value) = self { return value }
        return nil
    }
}

enum FeedbackError: LocalizedError, Equatable {
    case networkUnavailable
    case serverError(String)
    case invalidResponse
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network is unavailable."
        case .serverError(let message):
            return "Server error: \(message)"
        case .invalidResponse:
            return "Invalid response received."
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }

    static func == (lhs: FeedbackError, rhs: FeedbackError) -> Bool {
        switch (lhs, rhs) {
        case (.networkUnavailable, .networkUnavailable):
            return true
        case (.serverError(let a), .serverError(let b)):
            return a == b
        case (.invalidResponse, .invalidResponse):
            return true
        case (.unknown(let a), .unknown(let b)):
            return a == b
        default:
            return false
        }
    }
}