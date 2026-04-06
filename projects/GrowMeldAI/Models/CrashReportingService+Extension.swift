import Foundation

// MARK: - AppError

enum AppError: Error {
    case dataCorruption(entity: String, reason: String)
    case fileAccessFailed(path: String)
    case unknown(String)
}

// MARK: - ErrorCategory

enum ErrorCategory {
    case database
    case system
    case network
    case unknown
}

// MARK: - ErrorContext

struct ErrorContext {
    let category: ErrorCategory
    let userAction: String
    let metadata: [String: String]

    init(category: ErrorCategory, userAction: String, metadata: [String: String] = [:]) {
        self.category = category
        self.userAction = userAction
        self.metadata = metadata
    }
}

// MARK: - CrashReportingService

actor CrashReportingService {
    static let shared = CrashReportingService()

    private init() {}

    func recordError(_ error: Error, context: ErrorContext) async {
        var info = context.metadata
        info["category"] = "\(context.category)"
        info["userAction"] = context.userAction
        info["error"] = error.localizedDescription
        #if DEBUG
        print("[CrashReporting] Error recorded: \(error.localizedDescription) | context: \(info)")
        #endif
    }
}

// MARK: - CrashReportingService Convenience Extension

extension CrashReportingService {
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

    func recordFileAccessFailure(
        path: String,
        operation: String,
        underlyingError: Error?
    ) async {
        let context = ErrorContext(
            category: .system,
            userAction: operation,
            metadata: ["path": path]
        )
        let error = underlyingError ?? AppError.fileAccessFailed(path: path)
        await recordError(error, context: context)
    }
}