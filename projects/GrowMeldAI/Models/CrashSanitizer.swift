import Foundation

protocol CrashSanitizerProtocol: Sendable {
    func sanitize(_ error: Error, config: CrashReportingConfig) -> Error
    func sanitize(_ context: ErrorContext) -> ErrorContext
}

struct CrashReportingConfig: Sendable {
    let redactPersonalData: Bool
    let maxStackDepth: Int

    init(redactPersonalData: Bool = true, maxStackDepth: Int = 32) {
        self.redactPersonalData = redactPersonalData
        self.maxStackDepth = maxStackDepth
    }
}

struct ErrorContext: Sendable {
    let userId: String?
    let sessionId: String?
    let metadata: [String: String]

    init(userId: String? = nil, sessionId: String? = nil, metadata: [String: String] = [:]) {
        self.userId = userId
        self.sessionId = sessionId
        self.metadata = metadata
    }
}

struct DefaultCrashSanitizer: CrashSanitizerProtocol {
    func sanitize(_ error: Error, config: CrashReportingConfig) -> Error {
        return error
    }

    func sanitize(_ context: ErrorContext) -> ErrorContext {
        return ErrorContext(
            userId: nil,
            sessionId: context.sessionId,
            metadata: context.metadata
        )
    }
}