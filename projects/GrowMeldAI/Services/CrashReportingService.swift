import Foundation

enum CrashSeverity: String, Codable, Sendable {
    case low
    case medium
    case high
    case critical
}

enum CrashDataIntegrityStatus: String, Codable, Sendable {
    case healthy
    case degraded
    case corrupted
    case unknown
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

protocol CrashReportingService: AnyObject, Sendable {
    func reportQuestionError(
        questionID: String,
        category: String,
        errorDescription: String
    ) async throws

    func reportExamCrash(
        questionsAnswered: Int,
        timeRemaining: Int
    ) async throws

    func reportDataIntegrityIssue(_ issue: String, severity: CrashSeverity) async throws

    func getDataIntegrityStatus() -> CrashDataIntegrityStatus

    func hasConsentForCrashReporting() -> Bool

    func setConsentForCrashReporting(_ consent: Bool) async
}

final class DefaultCrashReportingService: CrashReportingService {
    private let defaults: UserDefaults
    private let consentKey = "crash_reporting_consent"
    private let integrityStatusKey = "crash_data_integrity_status"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func reportQuestionError(
        questionID: String,
        category: String,
        errorDescription: String
    ) async throws {
        guard hasConsentForCrashReporting() else {
            throw CrashReportingError.noConsent
        }
    }

    func reportExamCrash(
        questionsAnswered: Int,
        timeRemaining: Int
    ) async throws {
        guard hasConsentForCrashReporting() else {
            throw CrashReportingError.noConsent
        }
    }

    func reportDataIntegrityIssue(_ issue: String, severity: CrashSeverity) async throws {
        guard hasConsentForCrashReporting() else {
            throw CrashReportingError.noConsent
        }
        if severity == .critical || severity == .high {
            defaults.set(CrashDataIntegrityStatus.corrupted.rawValue, forKey: integrityStatusKey)
        }
    }

    func getDataIntegrityStatus() -> CrashDataIntegrityStatus {
        guard let raw = defaults.string(forKey: integrityStatusKey),
              let status = CrashDataIntegrityStatus(rawValue: raw) else {
            return .unknown
        }
        return status
    }

    func hasConsentForCrashReporting() -> Bool {
        return defaults.bool(forKey: consentKey)
    }

    func setConsentForCrashReporting(_ consent: Bool) async {
        defaults.set(consent, forKey: consentKey)
    }
}