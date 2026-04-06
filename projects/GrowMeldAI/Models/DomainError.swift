public enum DomainError: LocalizedError, Sendable {
    // ... existing cases ...
    case unknownError(String, underlyingError: (any Error)? = nil)
    
    // Adopt CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .unknownError(let message, let underlying):
            if let underlying = underlying {
                return "UnknownError: \(message) | Cause: \(type(of: underlying)).\(underlying)"
            }
            return "UnknownError: \(message)"
        default:
            return errorDescription ?? "Unknown"
        }
    }
    
    // Add LoggableError support for Sentry/Crashlytics
    public var loggableContext: [String: Any] {
        switch self {
        case .unknownError(let message, let underlying):
            var context: [String: Any] = ["message": message]
            if let underlying = underlying as? NSError {
                context["domain"] = underlying.domain
                context["code"] = underlying.code
                context["underlyingDescription"] = underlying.localizedDescription
            }
            return context
        default:
            return ["error": errorDescription ?? "Unknown"]
        }
    }
}