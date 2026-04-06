import Foundation

// MARK: - Validation Error

/// Represents validation failures throughout the application
enum ValidationError: Error, LocalizedError, Equatable {
    
    // MARK: - General
    case required(field: String)
    case invalidFormat(field: String, expected: String)
    case tooShort(field: String, minimum: Int)
    case tooLong(field: String, maximum: Int)
    case outOfRange(field: String, min: Double, max: Double)
    case invalidValue(field: String, value: String)
    
    // MARK: - Type Specific
    case invalidEmail
    case invalidURL
    case invalidPhoneNumber
    case invalidDate
    case invalidNumericValue(field: String)
    
    // MARK: - Business Logic
    case duplicateEntry(field: String)
    case notFound(resource: String)
    case unauthorized
    case conflict(description: String)
    
    // MARK: - Custom
    case custom(message: String)
    case multiple(errors: [ValidationError])
    
    // MARK: - LocalizedError
    
    var errorDescription: String? {
        switch self {
        case .required(let field):
            return "\(field) is required."
        case .invalidFormat(let field, let expected):
            return "\(field) has an invalid format. Expected: \(expected)."
        case .tooShort(let field, let minimum):
            return "\(field) must be at least \(minimum) characters long."
        case .tooLong(let field, let maximum):
            return "\(field) must be no more than \(maximum) characters long."
        case .outOfRange(let field, let min, let max):
            return "\(field) must be between \(min) and \(max)."
        case .invalidValue(let field, let value):
            return "\(field) has an invalid value: \(value)."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .invalidURL:
            return "Please enter a valid URL."
        case .invalidPhoneNumber:
            return "Please enter a valid phone number."
        case .invalidDate:
            return "Please enter a valid date."
        case .invalidNumericValue(let field):
            return "\(field) must be a valid number."
        case .duplicateEntry(let field):
            return "\(field) already exists."
        case .notFound(let resource):
            return "\(resource) could not be found."
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .conflict(let description):
            return "Conflict: \(description)."
        case .custom(let message):
            return message
        case .multiple(let errors):
            return errors.compactMap { $0.errorDescription }.joined(separator: "\n")
        }
    }
    
    var failureReason: String? {
        switch self {
        case .outOfRange(let field, let min, let max):
            return "\(field) value is outside the acceptable range of \(min)–\(max)."
        case .invalidFormat(let field, let expected):
            return "\(field) did not match the expected format: \(expected)."
        case .multiple(let errors):
            return errors.compactMap { $0.failureReason }.joined(separator: "; ")
        default:
            return errorDescription
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .required(let field):
            return "Please provide a value for \(field)."
        case .invalidEmail:
            return "Use the format: example@domain.com"
        case .invalidURL:
            return "Use the format: https://example.com"
        case .invalidPhoneNumber:
            return "Enter a phone number with country code, e.g. +1 555 000 0000."
        case .tooShort(let field, let minimum):
            return "Ensure \(field) has at least \(minimum) characters."
        case .tooLong(let field, let maximum):
            return "Shorten \(field) to \(maximum) characters or fewer."
        case .unauthorized:
            return "Please log in and try again."
        case .conflict(let description):
            return "Resolve the conflict before proceeding: \(description)."
        default:
            return nil
        }
    }
    
    // MARK: - Equatable
    
    static func == (lhs: ValidationError, rhs: ValidationError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
    
    // MARK: - Helpers
    
    /// Returns true if this error wraps multiple validation errors
    var isMultiple: Bool {
        if case .multiple = self { return true }
        return false
    }
    
    /// Flattened list of all errors (unwraps `.multiple`)
    var allErrors: [ValidationError] {
        if case .multiple(let errors) = self {
            return errors.flatMap { $0.allErrors }
        }
        return [self]
    }
    
    /// Combines an array of ValidationErrors into a single error
    static func combine(_ errors: [ValidationError]) -> ValidationError? {
        let flat = errors.flatMap { $0.allErrors }
        switch flat.count {
        case 0: return nil
        case 1: return flat[0]
        default: return .multiple(errors: flat)
        }
    }
}