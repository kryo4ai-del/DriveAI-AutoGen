// Services/Crashlytics/CrashSanitizer.swift
protocol CrashSanitizer: Sendable {
    func sanitize(_ error: Error, config: CrashReportingConfig) -> Error
    func sanitize(_ context: ErrorContext) -> ErrorContext
}
