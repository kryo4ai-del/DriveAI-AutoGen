// Sources/Services/CrashReporting/CrashReportingService.swift
import Foundation

/// Domain protocol for crash reporting - testable and Firebase-agnostic
protocol CrashReportingService: AnyObject, Sendable {
    /// Report an error during question answering
    func reportQuestionErr(
        questionID: String,
        category: String,
        errorDescription: String
    ) async throws

    /// Report crash during exam simulation
    func reportExamCra(
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

// Enum CrashReportingError declared in Models/FirebaseCrashlyticsAdapter.swift
