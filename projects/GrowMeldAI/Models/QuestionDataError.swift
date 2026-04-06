enum QuestionDataError: LocalizedError, Equatable {
    case fileNotFound(String)
    case invalidJSON(String)
    case decodingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let file):
            return "Questions file not found: \(file)"
        case .invalidJSON(let reason):
            return "Invalid JSON format: \(reason)"
        case .decodingFailed(let reason):
            return "Failed to decode questions: \(reason)"
        }
    }
}

// Caller handles errors explicitly
@Observable
class QuestionDataModel {
}