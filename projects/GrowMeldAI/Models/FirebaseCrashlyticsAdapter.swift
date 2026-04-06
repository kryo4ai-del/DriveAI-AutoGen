// Models/FirebaseCrashlyticsAdapter.swift
import Foundation

// MARK: - Severity

enum Severity {
    case low
    case medium
    case high
}

// MARK: - DataIntegrityStatus

struct DataIntegrityStatus {
    let isHealthy: Bool
    let issues: [String]
    let lastCheckDate: Date
}

// MARK: - CrashReportingError

enum CrashReportingError: Error {
    case noConsent
    case reportingFailed(String)
}

// MARK: - UserPreferencesService Protocol

protocol UserPreferencesService: AnyObject {
    var crashReportingConsent: Bool { get set }
}

// MARK: - CrashReportingService Protocol

protocol CrashReportingService: AnyObject {
    func reportQuestionError(
        questionID: String,
        category: String,
        errorDescription: String
    ) async throws

    func reportExamCrash(
        questionsAnswered: Int,
        timeRemaining: Int
    ) async throws

    func reportDataIntegrityIssue(
        _ issue: String,
        severity: Severity
    ) async throws

    func getDataIntegrityStatus() -> DataIntegrityStatus
    func hasConsentForCrashReporting() -> Bool
    func setConsentForCrashReporting(_ consent: Bool) async
}

// MARK: - CrashReport (internal model replacing Crashlytics)

private struct CrashReport {
    var customValues: [String: Any] = [:]
    var recordedErrors: [NSError] = []

    mutating func setCustomValue(_ value: Any, forKey key: String) {
        customValues[key] = value
    }

    mutating func record(error: NSError) {
        recordedErrors.append(error)
        #if DEBUG
        print("[CrashReporting] Recorded error: \(error.domain) - \(error.localizedDescription)")
        print("[CrashReporting] Custom values: \(customValues)")
        #endif
    }
}

// MARK: - FirebaseCrashlyticsAdapter

/// Production stub implementation — Firebase Crashlytics dependency is unavailable.
/// Replace the internal CrashReport usage with real Crashlytics calls once the
/// FirebaseCrashlytics package is added to the project.
final class FirebaseCrashlyticsAdapter: CrashReportingService {
    private let userPreferences: UserPreferencesService

    // Internal report buffer replaces direct Crashlytics SDK calls until
    // the package is available in the build environment.
    private var report = CrashReport()

    init(userPreferences: UserPreferencesService) {
        self.userPreferences = userPreferences
    }

    func reportQuestionError(
        questionID: String,
        category: String,
        errorDescription: String
    ) async throws {
        guard hasConsentForCrashReporting() else {
            throw CrashReportingError.noConsent
        }

        report.setCustomValue(questionID, forKey: "question_id")
        report.setCustomValue(category, forKey: "category")
        report.setCustomValue(errorDescription, forKey: "error_description")

        report.record(
            error: NSError(
                domain: "DriveAI.QuestionValidation",
                code: 42,
                userInfo: [NSLocalizedDescriptionKey: errorDescription]
            )
        )
    }

    func reportExamCrash(
        questionsAnswered: Int,
        timeRemaining: Int
    ) async throws {
        guard hasConsentForCrashReporting() else {
            throw CrashReportingError.noConsent
        }

        report.setCustomValue(questionsAnswered, forKey: "exam_questions_answered")
        report.setCustomValue(timeRemaining, forKey: "exam_time_remaining")

        report.record(
            error: NSError(
                domain: "DriveAI.ExamSimulation",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Exam simulation crashed"]
            )
        )
    }

    func reportDataIntegrityIssue(
        _ issue: String,
        severity: Severity
    ) async throws {
        guard hasConsentForCrashReporting() else {
            throw CrashReportingError.noConsent
        }

        report.setCustomValue(severity.rawValue, forKey: "severity")
        report.setCustomValue(issue, forKey: "integrity_issue")

        report.record(
            error: NSError(
                domain: "DriveAI.DataIntegrity",
                code: severity == .high ? 500 : 400,
                userInfo: [NSLocalizedDescriptionKey: issue]
            )
        )
    }

    func getDataIntegrityStatus() -> DataIntegrityStatus {
        // In production, this would validate local DB checksums
        DataIntegrityStatus(
            isHealthy: true,
            issues: [],
            lastCheckDate: Date()
        )
    }

    func hasConsentForCrashReporting() -> Bool {
        userPreferences.crashReportingConsent
    }

    func setConsentForCrashReporting(_ consent: Bool) async {
        await MainActor.run {
            userPreferences.crashReportingConsent = consent
        }
    }
}