// Services/ErrorReporting/ErrorReportingService.swift

import Foundation

/// Error severity for categorization and filtering
public enum ErrorSeverity: String, Codable, Sendable {
    case info
    case warning
    case critical
}

/// Constrained error report (size-limited, safe for storage/transmission)

/// Main error reporting abstraction
public protocol ErrorReportingService: AnyObject, Sendable {
    
    func logError(
        _ error: Error,
        severity: ErrorSeverity,
        message: String,
        userContext: [String: String]
    ) async
    
    func logMessage(_ message: String, level: ErrorSeverity) async
    
    func setUserContext(_ context: [String: String]) async
    
    func setConsent(granted: Bool) async
    
    func fetchLocalErrors(limit: Int) async -> [ErrorReport]
    
    func clearLocalErrors() async
}