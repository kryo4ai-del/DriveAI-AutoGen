// LocalDataModels.swift
import Foundation

/// Core local data models for DriveAI's offline-first architecture
/// These models support local persistence and optional Firebase sync

// MARK: - User Models

/// Local user profile with optional Firebase sync metadata
struct LocalUser: Identifiable, Codable {
    let id: UUID
    var firebaseUserId: String?
    var email: String
    var examDate: Date?
    var licenseCategory: String
    var createdAt: Date
    var updatedAt: Date

    // Sync metadata
    var lastSyncAttempt: Date?
    var lastSyncSuccess: Date?
    var needsSync: Bool

    init(id: UUID = UUID(),
         firebaseUserId: String? = nil,
         email: String,
         examDate: Date? = nil,
         licenseCategory: String,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         lastSyncAttempt: Date? = nil,
         lastSyncSuccess: Date? = nil,
         needsSync: Bool = false) {
        self.id = id
        self.firebaseUserId = firebaseUserId
        self.email = email
        self.examDate = examDate
        self.licenseCategory = licenseCategory
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastSyncAttempt = lastSyncAttempt
        self.lastSyncSuccess = lastSyncSuccess
        self.needsSync = needsSync
    }
}

/// User preferences with domain-specific settings

// MARK: - Progress Tracking

/// Spaced repetition algorithm implementation (SM-2 inspired)
struct SpacedRepetition {
    static func calculateNextReview(currentConfidence: Double,
                                  attemptCount: Int,
                                  correctRate: Double) -> Date {
        // Simplified SM-2 inspired algorithm
        let interval: TimeInterval

        if correctRate < 0.7 {
            interval = 1 * 24 * 3600 // 1 day
        } else if currentConfidence < 0.8 {
            interval = 3 * 24 * 3600 // 3 days
        } else if currentConfidence < 0.9 {
            interval = 7 * 24 * 3600 // 1 week
        } else {
            interval = 14 * 24 * 3600 // 2 weeks
        }

        return Date().addingTimeInterval(interval)
    }
}

/// Progress tracking for a specific category

// MARK: - Question & Exam Models

/// Question model with metadata

/// Exam session model

enum ExamMode: String, Codable {
    case practice
    case official
    case timed
}

// MARK: - Recommendation Models

/// Confidence-based recommendation for study focus
struct ConfidenceRecommendation: Identifiable, Codable {
    let id: UUID
    let categoryId: String
    let currentConfidence: Double
    let targetConfidence: Double
    let daysUntilExam: Int?
    let priority: RecommendationPriority
    let rationale: String

    var confidenceGap: Double {
        targetConfidence - currentConfidence
    }

    var isCritical: Bool {
        confidenceGap > 0.3 || priority == .critical
    }
}

enum RecommendationPriority: String, Codable {
    case low
    case medium
    case high
    case critical
}

// MARK: - Sync Models

/// Sync status and conflict resolution

struct SyncChange: Codable {
    let entityType: String
    let entityId: String
    let changeType: ChangeType
    let timestamp: Date
    let data: Data

    enum ChangeType: String, Codable {
        case create
        case update
        case delete
    }
}

struct SyncConflict: Codable {
    let entityType: String
    let entityId: String
    let localVersion: Data
    let remoteVersion: Data
    let resolution: ConflictResolution

    enum ConflictResolution: String, Codable {
        case useLocal
        case useRemote
        case merge
        case manual
    }
}