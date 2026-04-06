// Services/Crashlytics/ErrorContext.swift

import Foundation

/// Serializable value for Crashlytics custom keys
enum ContextValue: Sendable, Codable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    
    func toFirebaseValue() -> NSObject? {
        switch self {
        case .string(let value):
            return value as NSString
        case .int(let value):
            return NSNumber(value: value)
        case .double(let value):
            return NSNumber(value: value)
        case .bool(let value):
            return NSNumber(value: value)
        case .null:
            return nil
        }
    }
}

/// Structured error context for crash reporting

/// Breadcrumb severity levels
enum BreadcrumbLevel: String, Sendable, Codable {
    case debug
    case info
    case warning
    case error
}

/// Single breadcrumb entry
struct Breadcrumb: Sendable {
    let message: String
    let level: BreadcrumbLevel
    let timestamp: Date
}

/// Environment configuration

/// Domain-specific errors for better crash reporting