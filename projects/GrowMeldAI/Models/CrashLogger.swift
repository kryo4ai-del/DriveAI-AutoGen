// Services/Crashlytics/CrashLogger.swift
@MainActor
final class CrashLogger: ObservableObject {
    static let shared = CrashLogger()
    private let service = CrashlyticsService.shared
    
    func logError(_ error: Error, category: ErrorCategory, action: String?)
    func logDataCorruption(entity: String, reason: String)
    func logFileAccessFailure(path: String, operation: String)
}
