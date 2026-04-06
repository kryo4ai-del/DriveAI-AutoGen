// Services/ErrorReporting/ErrorReportingService.swift

import Foundation

/// Error severity for categorization and filtering
public enum ErrorSeverity: String, Codable, Sendable {
    case info
    case warning
    case critical
}

/// Constrained error report (size-limited, safe for storage/transmission)

// ErrorReportingService protocol declared in Services/ErrorReportingService.swift