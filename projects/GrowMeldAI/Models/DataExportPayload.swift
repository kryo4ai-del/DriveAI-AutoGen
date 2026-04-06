import Foundation

/// Complete user data export for GDPR Article 20 (data portability right)
struct DataExportPayload: Codable {
    let metadata: ExportMetadata
    let user: UserExportData
    let learning: LearningExportData
    let consent: ConsentExportData
    
    /// Generate ISO8601 timestamp for filename
    var exportFilename: String {
        let formatter = ISO8601DateFormatter()
        let timestamp = formatter.string(from: metadata.exportedAt)
            .replacingOccurrences(of: ":", with: "-")
        return "driveai-export-\(timestamp).json"
    }
}

// MARK: - Metadata

struct ExportMetadata: Codable {
    let exportedAt: Date
    let appVersion: String
    let iosVersion: String
    let language: String  // User's app language
    let policyVersion: String
    
    init() {
        self.exportedAt = Date()
        self.appVersion = Bundle.main.appVersion ?? "unknown"
        self.iosVersion = UIDevice.current.systemVersion
        self.language = Locale.current.language.languageCode?.identifier ?? "de"
        self.policyVersion = "1.0"  // Bump with policy updates
    }
}

// MARK: - User Data

struct UserExportData: Codable {
    let id: String
    let email: String?  // If user provided
    let createdAt: Date
    let lastActiveAt: Date
    let examDate: Date?
    
    /// Minimal PII — only what's necessary for user to identify their data
    var privacyMinimal: Bool { email == nil }
}

// MARK: - Learning Data

struct LearningExportData: Codable {
    let questionAttempts: [QuestionAttemptExport]
    let examResults: [ExamResultExport]
    let categoryProgress: [CategoryProgressExport]
    let totalQuestionsAnswered: Int
    let averageScore: Double
}

struct QuestionAttemptExport: Codable {
    let questionId: String
    let selectedAnswerId: String
    let isCorrect: Bool
    let timeSpent: TimeInterval
    let attemptedAt: Date
    let categoryId: String
}

struct ExamResultExport: Codable {
    let examId: String
    let score: Int
    let maxScore: Int
    let isPassed: Bool
    let durationSeconds: Int
    let completedAt: Date
    let questionAnswers: [QuestionAttemptExport]
}

struct CategoryProgressExport: Codable {
    let categoryId: String
    let categoryName: String
    let totalQuestions: Int
    let correctAnswers: Int
    let lastReviewedAt: Date?
}

// MARK: - Consent Data

struct ConsentExportData: Codable {
    let preferences: [ConsentPreference]
    let auditLog: [ConsentAuditEntry]
    let currentPolicyVersion: String
}

// MARK: - Serialization Helpers

extension DataExportPayload {
    /// Encode to JSON with human-readable formatting
    func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
    
    /// Create from JSON (for testing / re-import)
    static func fromJSON(_ data: Data) throws -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Self.self, from: data)
    }
}