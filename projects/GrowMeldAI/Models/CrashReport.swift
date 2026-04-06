import Foundation

// MARK: - CrashReport

struct CrashReport: Codable, Sendable {
    let id: UUID
    let timestamp: Date
    let errorType: String
    let errorDescription: String
    let context: ErrorContext
    let severity: CrashSeverity

    init(error: Error, context: ErrorContext, severity: CrashSeverity) {
        self.id = UUID()
        self.timestamp = Date()
        self.errorType = String(describing: type(of: error))
        self.errorDescription = error.localizedDescription
        self.context = context
        self.severity = severity
    }
}

// MARK: - CrashSeverity

enum CrashSeverity: String, Codable, Sendable {
    case critical
    case high
    case medium
    case low

    static func from(_ error: Error) -> CrashSeverity {
        switch error {
        case AppError.dataCorruption:
            return .critical
        case AppError.fileAccessFailed:
            return .high
        default:
            return .medium
        }
    }
}

// MARK: - ErrorContext + Codable

extension ErrorContext: Codable {
    enum CodingKeys: String, CodingKey {
        case category
        case userAction
        case metadata
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let categoryString = try container.decode(String.self, forKey: .category)
        switch categoryString {
        case "database": self.category = .database
        case "network": self.category = .network
        case "system": self.category = .system
        default: self.category = .unknown
        }
        self.userAction = try container.decode(String.self, forKey: .userAction)
        self.metadata = try container.decode([String: String].self, forKey: .metadata)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let categoryString: String
        switch category {
        case .database: categoryString = "database"
        case .network: categoryString = "network"
        case .system: categoryString = "system"
        case .unknown: categoryString = "unknown"
        }
        try container.encode(categoryString, forKey: .category)
        try container.encode(userAction, forKey: .userAction)
        try container.encode(metadata, forKey: .metadata)
    }
}