// BackupModels.swift
import Foundation

// MARK: - Consent & Privacy
enum BackupConsent: String, Codable {
    case granted
    case denied
    case expired
}

// MARK: - Retention Policy

// MARK: - Backup Integrity
struct BackupIntegrityCheck: Codable {
    let dataHash: String
    let timestamp: Date
    let schemaVersion: String

    static func compute(for data: Data) -> BackupIntegrityCheck {
        let hash = SHA256.hash(data: data).hexString
        return BackupIntegrityCheck(
            dataHash: hash,
            timestamp: Date(),
            schemaVersion: "1.0"
        )
    }

    func verify(data: Data) -> Bool {
        let currentHash = SHA256.hash(data: data).hexString
        return currentHash == dataHash
    }
}

// MARK: - Backup Context
struct BackupExamContext: Codable {
    let userId: String
    let examDate: Date?
    let categoryIds: [String]
    let consent: BackupConsent
    let retentionPolicy: BackupRetentionPolicy
    let createdAt: Date

    init(userId: String, examDate: Date? = nil, categoryIds: [String], consent: BackupConsent, retentionPolicy: BackupRetentionPolicy = .untilUserDeletion) {
        self.userId = userId
        self.examDate = examDate
        self.categoryIds = categoryIds
        self.consent = consent
        self.retentionPolicy = retentionPolicy
        self.createdAt = Date()
    }
}

// MARK: - Backup Result Types
enum BackupResult: Equatable {
    case success(BackupMetadata)
    case failure(BackupError)
}

enum RestoreResult: Equatable {
    case success(BackupExamContext)
    case failure(BackupError)
}

// MARK: - Backup Data Structures

struct ProgressData: Codable {
    let completedQuestions: [String]
    let incorrectAnswers: [String]
    let lastSession: Date?
    let streakCount: Int
}

struct ProfileData: Codable {
    let userName: String
    let email: String?
    let examAttempts: Int
    let preferredCategories: [String]
}