import Foundation

enum DataLoadError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String)
    case networkError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "File not found: \(name)"
        case .decodingFailed(let reason):
            return "Decoding failed: \(reason)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .unknown(let reason):
            return "Unknown error: \(reason)"
        }
    }
}