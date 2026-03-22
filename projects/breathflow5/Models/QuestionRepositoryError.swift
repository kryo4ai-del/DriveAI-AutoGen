enum QuestionRepositoryError: LocalizedError {
    case networkConnectionLost
    case timeout
    case invalidResponse(statusCode: Int)
    case decodingFailure(DecodingError)
    case notFound
    case serverError(statusCode: Int)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkConnectionLost:
            return "No internet connection. Check your network."
        case .timeout:
            return "Request timed out. Please try again."
        case .invalidResponse(let code):
            return "Server error (\(code)). Please try later."
        case .decodingFailure:
            return "Failed to load questions. Try again."
        case .notFound:
            return "Questions not found."
        case .serverError(let code):
            return "Server error (\(code))."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkConnectionLost:
            return "Enable Wi-Fi or cellular data."
        case .timeout:
            return "Tap 'Retry' to try again."
        case .invalidResponse, .serverError:
            return "Tap 'Retry' later."
        default:
            return "Try again."
        }
    }
}