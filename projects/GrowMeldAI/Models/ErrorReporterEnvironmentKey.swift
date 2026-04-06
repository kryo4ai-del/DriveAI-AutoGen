private struct ErrorReporterEnvironmentKey: EnvironmentKey {
    static let defaultValue: ErrorReportingService = {
        // Lazy singleton or shared instance
        LocalErrorLogger()
    }()  // ← Execute once
}