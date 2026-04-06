// Sources/Services/ErrorReporting/ErrorReportingService.swift
import Foundation

/// Main error reporting abstraction
public protocol ErrorReportingService: AnyObject, Sendable {

    /// Log an error (may be stored locally or sent, depending on consent/impl)
    func logError(
        _ error: Error,
        severity: ErrorSeverity,
        message: String,
        userContext: [String: String]
    ) async

    /// Log a message (for breadcrumbs/context)
    func logMessage(_ message: String, level: ErrorSeverity) async

    /// Set user context (only safe, non-PII data)
    func setUserContext(_ context: [String: String]) async

    /// Update consent state (only used post-legal-approval)
    func setConsent(granted: Bool) async

    /// Fetch recent error reports (for debugging/QA)
    func fetchLocalErrors(limit: Int) async -> [ErrorReport]

    /// Clear local error history
    func clearLocalErrors() async
}