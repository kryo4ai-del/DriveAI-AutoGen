import Foundation

struct ErrorContext: Sendable, Codable {
    let category: ErrorCategory
    let sessionID: UUID
    let timestamp: Date
    let errorType: String
    let stackTrace: String?
    let metadata: [String: String]
    let userAction: String?
}