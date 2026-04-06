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

// MARK: - Supporting Domain Models

struct FirestoreUserPreferences: Codable {
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

struct FirestoreUserStatistics: Codable {
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

struct FirestoreUserProfile: Identifiable, Codable {
    var id: String
    var email: String
    var displayName: String?
    var examDate: Date
    var licenseClass: String?
    var preferences: FirestoreUserPreferences
    var statistics: FirestoreUserStatistics

    init(
        id: String,
        email: String,
        displayName: String? = nil,
        examDate: Date,
        licenseClass: String? = nil,
        preferences: FirestoreUserPreferences = FirestoreUserPreferences(),
        statistics: FirestoreUserStatistics = FirestoreUserStatistics()
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

struct FirestoreCategoryProgress: Identifiable, Codable {
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

    var completionPercentage: Double {
        guard totalQuestions > 0 else { return 0.0 }
        return Double(answeredQuestions) / Double(totalQuestions)
    }

    var accuracyPercentage: Double {
        guard answeredQuestions > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(answeredQuestions)
    }

    func validate() throws {
        let sum = correctAnswers + incorrectAnswers + skippedQuestions
        if sum != answeredQuestions {
            throw FirestoreError.invalidProgressState
        }
    }
}