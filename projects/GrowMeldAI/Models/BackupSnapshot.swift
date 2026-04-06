// Models/Backup/BackupModels.swift

import Foundation

// MARK: - Backup Snapshot
struct BackupSnapshot: Codable, Identifiable {
    let id: String
    let timestamp: Date
    let version: Int
    let checksum: String
    let size: UInt64
    
    /// Runtime-only: file location (not serialized)
    var fileURL: URL?
    
    init(
        id: String = UUID().uuidString,
        timestamp: Date = .now,
        version: Int = 1,
        checksum: String,
        size: UInt64,
        fileURL: URL? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.version = version
        self.checksum = checksum
        self.size = size
        self.fileURL = fileURL
    }
    
    enum CodingKeys: String, CodingKey {
        case id, timestamp, version, checksum, size
        // fileURL excluded from Codable
    }
}

// MARK: - Backup Metadata
struct BackupMetadata: Codable, Identifiable {
    let id: String
    let timestamp: Date
    let displayName: String
    let size: String  // Human-readable: "2.5 MB"
    let version: Int
    let isValid: Bool
    
    var formattedDate: String {
        DateFormatter.backup.string(from: timestamp)
    }
}

extension DateFormatter {
    static let backup: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
}

// MARK: - Backup Payload

struct UserProgressSnapshot: Codable, Identifiable {
    let id: String
    let categoryId: String
    let correctAnswers: Int
    let totalQuestions: Int
    let lastUpdated: Date
}

struct ExamSessionSnapshot: Codable, Identifiable {
    let id: String
    let startTime: Date
    let endTime: Date?
    let score: Int
    let totalQuestions: Int
    let isPassed: Bool
    let answers: [String: Bool]  // questionId -> isCorrect
}

struct UserSettingsSnapshot: Codable {
    let examDate: Date?
    let autoBackupEnabled: Bool
    let backupFrequency: TimeInterval
}

// MARK: - Errors

// MARK: - Migration Version