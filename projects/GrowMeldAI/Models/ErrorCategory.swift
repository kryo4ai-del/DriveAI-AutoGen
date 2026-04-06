enum ErrorCategory: String, Sendable, Codable {
    case network  // URLError, DNS issues
    case database  // SQLite errors, JSON decode
    case fileIO  // File not found, write permission
    case validation  // Invalid data format
    case system  // Out of memory, device issues
    case unknown  // Catch-all
    
    static func categorize(_ error: Error) -> ErrorCategory {
        switch error {
        case is URLError: return .network
        case is DecodingError: return .database
        case is NSError where error.domain == NSCocoaErrorDomain: return .fileIO
        default: return .unknown
        }
    }
}