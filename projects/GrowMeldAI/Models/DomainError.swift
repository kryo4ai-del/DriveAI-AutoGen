import Foundation

public enum DomainError: LocalizedError, Sendable {
    case unknownError(String, underlyingError: (any Error)? = nil)

    public var errorDescription: String? {
        switch self {
        case .unknownError(let message, _):
            return message
        }
    }

    public var debugDescription: String {
        switch self {
        case .unknownError(let message, let underlying):
            if let underlying = underlying {
                return "UnknownError: \(message) | Cause: \(type(of: underlying)).\(underlying)"
            }
            return "UnknownError: \(message)"
        }
    }

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
        }
    }
}