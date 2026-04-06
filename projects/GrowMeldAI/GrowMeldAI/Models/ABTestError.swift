import Foundation

enum ABTestError: LocalizedError, Equatable {
    case databaseError(String)
    case invalidTest(String)
    case assignmentFailed(String)
    case invalidVariants(String)
    case persistenceFailed(String)
    case threadSafetyViolation(String)
    
    var errorDescription: String? {
        switch self {
        case .databaseError(let msg):
            return "A/B Test Database Error: \(msg)"
        case .invalidTest(let id):
            return "Test not found or invalid: \(id)"
        case .assignmentFailed(let reason):
            return "Failed to assign variant: \(reason)"
        case .invalidVariants(let reason):
            return "Invalid variant configuration: \(reason)"
        case .persistenceFailed(let reason):
            return "Failed to persist A/B result: \(reason)"
        case .threadSafetyViolation(let reason):
            return "Thread safety violation: \(reason)"
        }
    }
    
    var recoverySuggestion: String? {
        return "Check database integrity and ensure A/B testing tables are created."
    }
    
    static func == (lhs: ABTestError, rhs: ABTestError) -> Bool {
        switch (lhs, rhs) {
        case (.databaseError(let a), .databaseError(let b)):
            return a == b
        case (.invalidTest(let a), .invalidTest(let b)):
            return a == b
        case (.assignmentFailed(let a), .assignmentFailed(let b)):
            return a == b
        case (.invalidVariants(let a), .invalidVariants(let b)):
            return a == b
        case (.persistenceFailed(let a), .persistenceFailed(let b)):
            return a == b
        case (.threadSafetyViolation(let a), .threadSafetyViolation(let b)):
            return a == b
        default:
            return false
        }
    }
}