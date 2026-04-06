// Sources/Services/CrashReporting/MockCrashReportingService.swift
import Foundation

/// Test double for crash reporting
final class MockCrashReportingService: CrashReportingService {
    private let lock = NSLock()
    private var _reportedEvents: [CrashEvent] = []
    private var _consentGiven = true

    var reportedEvents: [CrashEvent] {
        lock.lock()
        defer { lock.unlock() }
        return _reportedEvents
    }

    var shouldFailValidation = false

    func reportQuestionError(
        questionID: String,
        category: String,
        errorDescription: String
    ) async throws {
        guard !shouldFailValidation else {
            throw CrashReportingError.questionValidationFailed("Mock validation failed")
        }

        let context = QuestionErrorContext(
            questionID: questionID,
            category: category,
            attemptCount: 1,
            timeSpentSeconds: 30
        )

        let learnerState = LearnerStateSnapshot(
            currentStreak: 5,
            totalQuestionsAttempted: 100,
            categoryProgress: ["Vorfahrt": 85, "Geschwindigkeit": 70]
        )

        let event = CrashEvent(
            context: .questionValidation(context),
            learnerState: learnerState,
            errorDescription: errorDescription,
            consentGiven: _consentGiven
        )

        lock.lock()
        _reportedEvents.append(event)
        lock.unlock()
    }

    func reportExamCrash(
        questionsAnswered: Int,
        timeRemaining: Int
    ) async throws {
        let snapshot = ExamSessionSnapshot(
            questionsAnswered: questionsAnswered,
            totalQuestions: 30,
            timeRemainingSeconds: timeRemaining,
            currentScore: questionsAnswered * 3
        )

        let learnerState = LearnerStateSnapshot(
            currentStreak: 3,
            totalQuestionsAttempted: 150,
            categoryProgress: ["Vorfahrt": 90, "Verhalten": 60]
        )

        let event = CrashEvent(
            context: .examCrash(snapshot),
            learnerState: learnerState,
            errorDescription: "Exam simulation crashed",
            consentGiven: _consentGiven
        )

        lock.lock()
        _reportedEvents.append(event)
        lock.unlock()
    }

    func reportDataIntegrityIssue(
        _ issue: String,
        severity: Severity
    ) async throws {
        let details = DataCorruptionDetails(
            affectedEntity: "LocalDatabase",
            issueType: issue,
            severity: severity
        )

        let learnerState = LearnerStateSnapshot(
            currentStreak: 2,
            totalQuestionsAttempted: 80,
            categoryProgress: ["Schilder": 75]
        )

        let event = CrashEvent(
            context: .dataIntegrityIssue(details),
            learnerState: learnerState,
            errorDescription: "Data integrity issue detected",
            consentGiven: _consentGiven
        )

        lock.lock()
        _reportedEvents.append(event)
        lock.unlock()
    }

    func getDataIntegrityStatus() -> DataIntegrityStatus {
        DataIntegrityStatus(
            isHealthy: true,
            issues: [],
            lastCheckDate: Date()
        )
    }

    func hasConsentForCrashReporting() -> Bool {
        _consentGiven
    }

    func setConsentForCrashReporting(_ consent: Bool) async {
        _consentGiven = consent
    }

    func clearReportedEvents() {
        lock.lock()
        _reportedEvents.removeAll()
        lock.unlock()
    }
}