// Models/FirestoreUserProfile.swift
import Foundation

// MARK: - DocumentID Property Wrapper (Firestore-free fallback)

@propertyWrapper
struct DocumentID: Codable, Sendable {
    var wrappedValue: String?

    init(wrappedValue: String? = nil) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try? container.decode(String.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

// MARK: - Firestore Errors

enum FirestoreError: Error, LocalizedError {
    case missingDocumentId
    case invalidProgressState
    case invalidExamType
    case validationFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingDocumentId:
            return "Document is missing its Firestore ID."
        case .invalidProgressState:
            return "Progress state is inconsistent: answered count does not match sum of correct, incorrect, and skipped."
        case .invalidExamType:
            return "The exam type value stored in Firestore is not recognized."
        case .validationFailed(let reason):
            return "Validation failed: \(reason)"
        }
    }
}

// MARK: - Supporting Domain Models (minimal stubs if not defined elsewhere)

struct UserPreferences: Codable {
    var dailyGoalMinutes: Int
    var notificationsEnabled: Bool
    var preferredStudyTime: String?

    init(
        dailyGoalMinutes: Int = 30,
        notificationsEnabled: Bool = true,
        preferredStudyTime: String? = nil
    ) {
        self.dailyGoalMinutes = dailyGoalMinutes
        self.notificationsEnabled = notificationsEnabled
        self.preferredStudyTime = preferredStudyTime
    }
}

struct UserStatistics: Codable {
    var totalQuestionsAnswered: Int
    var totalCorrect: Int
    var totalExamsTaken: Int
    var currentStreak: Int
    var longestStreak: Int

    init(
        totalQuestionsAnswered: Int = 0,
        totalCorrect: Int = 0,
        totalExamsTaken: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0
    ) {
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.totalCorrect = totalCorrect
        self.totalExamsTaken = totalExamsTaken
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
    }
}

struct UserProfile: Identifiable {
    var id: String
    var email: String
    var displayName: String?
    var examDate: Date
    var licenseClass: String?
    var preferences: UserPreferences
    var statistics: UserStatistics

    init(
        id: String,
        email: String,
        displayName: String? = nil,
        examDate: Date,
        licenseClass: String? = nil,
        preferences: UserPreferences = UserPreferences(),
        statistics: UserStatistics = UserStatistics()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.examDate = examDate
        self.licenseClass = licenseClass
        self.preferences = preferences
        self.statistics = statistics
    }
}

struct CategoryProgress: Identifiable {
    var id: String
    var categoryName: String
    var categoryIcon: String?
    var totalQuestions: Int
    var answeredQuestions: Int
    var correctAnswers: Int
    var incorrectAnswers: Int
    var skippedQuestions: Int
    var lastAnsweredAt: Date?

    init(
        id: String,
        categoryName: String,
        categoryIcon: String? = nil,
        totalQuestions: Int,
        answeredQuestions: Int,
        correctAnswers: Int,
        incorrectAnswers: Int,
        skippedQuestions: Int,
        lastAnsweredAt: Date? = nil
    ) {
        self.id = id
        self.categoryName = categoryName
        self.categoryIcon = categoryIcon
        self.totalQuestions = totalQuestions
        self.answeredQuestions = answeredQuestions
        self.correctAnswers = correctAnswers
        self.incorrectAnswers = incorrectAnswers
        self.skippedQuestions = skippedQuestions
        self.lastAnsweredAt = lastAnsweredAt
    }
}

enum ExamType: String, Codable {
    case practice
    case mock
    case official
    case custom
}

struct ExamCategoryResult: Codable {
    var totalQuestions: Int
    var correctAnswers: Int

    init(totalQuestions: Int, correctAnswers: Int) {
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
    }
}

struct ExamRecord: Identifiable {
    var id: String
    var startedAt: Date
    var completedAt: Date
    var createdAt: Date
    var durationSeconds: Int
    var totalQuestions: Int
    var correctAnswers: Int
    var categoryBreakdown: [String: ExamCategoryResult]
    var examType: ExamType

    init(
        id: String,
        startedAt: Date,
        completedAt: Date,
        createdAt: Date,
        durationSeconds: Int,
        totalQuestions: Int,
        correctAnswers: Int,
        categoryBreakdown: [String: ExamCategoryResult],
        examType: ExamType
    ) {
        self.id = id
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.durationSeconds = durationSeconds
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.categoryBreakdown = categoryBreakdown
        self.examType = examType
    }
}

// MARK: - Validators

enum UserProfileValidator {
    static func validate(_ profile: UserProfile) throws {
        guard !profile.email.isEmpty else {
            throw FirestoreError.validationFailed("Email must not be empty.")
        }
        guard !profile.id.isEmpty else {
            throw FirestoreError.validationFailed("Profile ID must not be empty.")
        }
    }
}

enum ExamRecordValidator {
    static func validate(_ record: ExamRecord) throws {
        guard record.correctAnswers <= record.totalQuestions else {
            throw FirestoreError.validationFailed("Correct answers cannot exceed total questions.")
        }
        guard record.durationSeconds >= 0 else {
            throw FirestoreError.validationFailed("Duration must be non-negative.")
        }
    }
}

// MARK: - FirestoreUserProfile

struct FirestoreUserProfile: Identifiable, Codable {
    @DocumentID var id: String?

    var email: String
    var displayName: String?
    var examDate: Date
    var licenseClass: String?
    var preferences: UserPreferences
    var statistics: UserStatistics

    // Server-managed timestamps (never set client-side)
    var createdAt: Date
    var updatedAt: Date
    var lastSyncedAt: Date?

    // Conversion to domain model
    func toDomain() throws -> UserProfile {
        guard let id = id else { throw FirestoreError.missingDocumentId }

        let profile = UserProfile(
            id: id,
            email: email,
            displayName: displayName,
            examDate: examDate,
            licenseClass: licenseClass,
            preferences: preferences,
            statistics: statistics
        )

        try UserProfileValidator.validate(profile)
        return profile
    }

    // Conversion from domain model (for writes, omit timestamps)
    static func fromDomain(_ profile: UserProfile) -> FirestoreUserProfile {
        return FirestoreUserProfile(
            email: profile.email,
            displayName: profile.displayName,
            examDate: profile.examDate,
            licenseClass: profile.licenseClass,
            preferences: profile.preferences,
            statistics: profile.statistics,
            createdAt: Date(),  // Will be overwritten by server
            updatedAt: Date()   // Will be overwritten by server
        )
    }
}

// MARK: - FirestoreCategoryProgress

struct FirestoreCategoryProgress: Identifiable, Codable {
    @DocumentID var id: String?

    var categoryName: String
    var categoryIcon: String?

    var totalQuestions: Int
    var answeredQuestions: Int
    var correctAnswers: Int
    var incorrectAnswers: Int
    var skippedQuestions: Int

    var lastAnsweredAt: Date?
    var createdAt: Date
    var updatedAt: Date

    func toDomain() throws -> CategoryProgress {
        guard let id = id else { throw FirestoreError.missingDocumentId }

        let progress = CategoryProgress(
            id: id,
            categoryName: categoryName,
            categoryIcon: categoryIcon,
            totalQuestions: totalQuestions,
            answeredQuestions: answeredQuestions,
            correctAnswers: correctAnswers,
            incorrectAnswers: incorrectAnswers,
            skippedQuestions: skippedQuestions,
            lastAnsweredAt: lastAnsweredAt
        )

        // Validate invariants
        let sum = correctAnswers + incorrectAnswers + skippedQuestions
        if sum != answeredQuestions {
            throw FirestoreError.invalidProgressState
        }

        return progress
    }

    static func fromDomain(_ progress: CategoryProgress) -> FirestoreCategoryProgress {
        return FirestoreCategoryProgress(
            categoryName: progress.categoryName,
            categoryIcon: progress.categoryIcon,
            totalQuestions: progress.totalQuestions,
            answeredQuestions: progress.answeredQuestions,
            correctAnswers: progress.correctAnswers,
            incorrectAnswers: progress.incorrectAnswers,
            skippedQuestions: progress.skippedQuestions,
            lastAnsweredAt: progress.lastAnsweredAt,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - FirestoreExamRecord

struct FirestoreExamRecord: Identifiable, Codable {
    @DocumentID var id: String?

    var startedAt: Date
    var completedAt: Date
    var createdAt: Date  // Server-set, immutable

    var durationSeconds: Int
    var totalQuestions: Int
    var correctAnswers: Int
    var categoryBreakdown: [String: ExamCategoryResult]
    var examType: String

    func toDomain() throws -> ExamRecord {
        guard let id = id else { throw FirestoreError.missingDocumentId }
        guard let type = ExamType(rawValue: examType) else {
            throw FirestoreError.invalidExamType
        }

        let record = ExamRecord(
            id: id,
            startedAt: startedAt,
            completedAt: completedAt,
            createdAt: createdAt,
            durationSeconds: durationSeconds,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            categoryBreakdown: categoryBreakdown,
            examType: type
        )

        try ExamRecordValidator.validate(record)
        return record
    }

    static func fromDomain(_ exam: ExamRecord) -> FirestoreExamRecord {
        return FirestoreExamRecord(
            startedAt: exam.startedAt,
            completedAt: exam.completedAt,
            createdAt: exam.createdAt,  // Client provides, server must validate
            durationSeconds: exam.durationSeconds,
            totalQuestions: exam.totalQuestions,
            correctAnswers: exam.correctAnswers,
            categoryBreakdown: exam.categoryBreakdown,
            examType: exam.examType.rawValue
        )
    }
}