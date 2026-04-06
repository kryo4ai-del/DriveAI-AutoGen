// Models/ErrorContext.swift
struct ErrorContext: Sendable, Codable {
    let category: ErrorCategory
    let sessionID: UUID
    let timestamp: Date
    let errorType: String  // Serialized type name, not the Error object
    let stackTrace: String?  // Serialized stack, not NSException
    let metadata: [String: String]  // String only, no Any
    let userAction: String?  // Optional, but String only
}