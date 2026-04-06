// Sources/Services/CrashReporting/CrashReportingService.swift
import Foundation

/// Domain protocol for crash reporting - testable and Firebase-agnostic
protocol CrashReportingService: AnyObject, Sendable {
    /// Report an error during question answering
    func reportQuestionError(
        questionID: String,
        category: String,
        errorDescription: String
    ) async throws

    /// Report crash during exam simulation
    func reportExamCrash(
        questionsAnswered: Int,
        timeRemaining: Int
    ) async throws

    /// Capture data integrity issues (DB corruption, etc.)
    func reportDataIntegrityIssue(_ issue: String, severity: Severity) async throws

    /// Get current health status
    func getDataIntegrityStatus() -> DataIntegrityStatus

    /// Check if user has consented to crash reporting
    func hasConsentForCrashReporting() -> Bool

    /// Set consent status (async to allow persistence)
    func setConsentForCrashReporting(_ consent: Bool) async
}

enum CrashReportingError: Error, LocalizedError, Sendable {
    case noConsent
    case privacyViolation(String)
    case dataCorruption(String)
    case questionValidationFailed(String)
    case examSimulationCrash(String)

    var errorDescription: String? {
        switch self {
        case .noConsent:
            return "Crash reporting requires user consent"
        case .privacyViolation(let details):
            return "Privacy violation: \(details)"
        case .dataCorruption(let issue):
            return "Data corruption detected: \(issue)"
        case .questionValidationFailed(let error):
            return "Question validation failed: \(error)"
        case .examSimulationCrash(let context):
            return "Exam simulation crashed: \(context)"
        }
    }
}