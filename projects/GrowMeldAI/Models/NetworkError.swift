import Foundation
enum NetworkError: LocalizedError {
    case offline
    case timeout
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .offline:
            return "No network connection available"  // ❌ ENGLISH
        case .timeout:
            return "Request timed out"  // ❌ ENGLISH
        case .invalidURL:
            return "Invalid endpoint URL"  // ❌ ENGLISH
        }
    }
}