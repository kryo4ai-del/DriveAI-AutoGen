// Services/Crashlytics/CrashReportingService.swift
import Foundation
import FirebaseCrashlytics

/// Main service for crash reporting and error logging
actor CrashReportingService {
    static let shared = CrashReportingService()

    private var firebaseService: FirebaseService
    private let sanitizer: CrashSanitizer
    private let queue: EventQueue<CrashReport>
    private var config: CrashReportingConfig

    private init(
        firebaseService: FirebaseService = FirebaseCrashlyticsAdapter(),
        sanitizer: CrashSanitizer = DefaultCrashSanitizer.shared,
        config: CrashReportingConfig = .disabled
    ) {
        self.firebaseService = firebaseService
        self.sanitizer = sanitizer
        self.config = config
        self.queue = EventQueue(fileName: "crash_reports", maxSize: config.maxQueueSize)
    }

    /// Initialize with configuration
    func initialize(with config: CrashReportingConfig) async {
        self.config = config
        await queue.updateMaxSize(config.maxQueueSize)

        if config.isEnabled {
            await setCustomValue("enabled", forKey: "crash_reporting")
        }
    }

    /// Record a non-fatal error with context
    func recordError(_ error: Error, context: ErrorContext) async {
        guard config.isEnabled else { return }

        let sanitizedContext = sanitizer.sanitize(context)
        let report = CrashReport(
            error: error,
            context: sanitizedContext,
            severity: .from(error)
        )

        await enqueueAndSync(report)
    }

    /// Record a data corruption issue
    func recordDataCorruption(
        entity: String,
        reason: String,
        userAction: String? = nil
    ) async {
        let context = ErrorContext(
            category: .database,
            userAction: userAction ?? "data_corruption",
            metadata: ["entity": entity, "reason": reason]
        )

        let error = AppError.dataCorruption(entity: entity, reason: reason)
        await recordError(error, context: context)
    }

    /// Record a file access failure
    func recordFileAccessFailure(
        path: String,
        operation: String,
        underlyingError: Error? = nil
    ) async {
        let context = ErrorContext(
            category: .fileIO,
            userAction: operation,
            metadata: ["path": path]
        )

        let error = underlyingError ?? AppError.fileAccessFailed(path: path)
        await recordError(error, context: context)
    }

    /// Set user identifier for crash grouping
    func setUserID(_ id: String?) async {
        await firebaseService.setUserID(id)
    }

    /// Flush queued reports
    func flush() async {
        await queue.flush()
    }

    // MARK: - Private Methods

    private func enqueueAndSync(_ report: CrashReport) async {
        do {
            try await queue.enqueue(report)
            await flushIfNeeded()
        } catch {
            print("Failed to enqueue crash report: \(error)")
        }
    }

    private func flushIfNeeded() async {
        // Flush periodically or when queue reaches threshold
        if await queue.count >= config.maxQueueSize / 2 {
            await flush()
        }
    }

    private func setCustomValue(_ value: Any, forKey key: String) async {
        await firebaseService.setCustomValue(value, forKey: key)
    }
}

// Supporting types
private struct CrashReport: Codable, Sendable {
    let id: UUID
    let timestamp: Date
    let errorType: String
    let errorDescription: String
    let context: ErrorContext
    let severity: CrashSeverity

    init(error: Error, context: ErrorContext, severity: CrashSeverity) {
        self.id = UUID()
        self.timestamp = Date()
        self.errorType = String(describing: type(of: error))
        self.errorDescription = String(describing: error)
        self.context = context
        self.severity = severity
    }
}

private enum CrashSeverity: String, Codable, Sendable {
    case critical
    case high
    case medium
    case low

    static func from(_ error: Error) -> CrashSeverity {
        switch error {
        case is AppError: return .high
        case let urlError as URLError where urlError.code == .timedOut: return .medium
        default: return .low
    }
}