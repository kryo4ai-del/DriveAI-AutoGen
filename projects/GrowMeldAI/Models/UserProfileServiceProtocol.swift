import Foundation

// MARK: - Supporting Types

struct UserProfile: Codable, Sendable {
    var id: String
    var name: String
    var examDate: Date?
    var categoryProgress: [String: CategoryProgress]
    var examAttempts: [ExamAttempt]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String = "",
        examDate: Date? = nil,
        categoryProgress: [String: CategoryProgress] = [:],
        examAttempts: [ExamAttempt] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.examDate = examDate
        self.categoryProgress = categoryProgress
        self.examAttempts = examAttempts
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct CategoryProgress: Codable, Sendable {
    var categoryId: String
    var categoryName: String
    var totalAnswered: Int
    var totalCorrect: Int

    var accuracy: Double {
        guard totalAnswered > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalAnswered)
    }

    init(categoryId: String, categoryName: String, totalAnswered: Int = 0, totalCorrect: Int = 0) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.totalAnswered = totalAnswered
        self.totalCorrect = totalCorrect
    }
}

struct ExamAttempt: Codable, Sendable, Identifiable {
    var id: String
    var date: Date
    var score: Int
    var totalQuestions: Int
    var passed: Bool

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        score: Int,
        totalQuestions: Int,
        passed: Bool
    ) {
        self.id = id
        self.date = date
        self.score = score
        self.totalQuestions = totalQuestions
        self.passed = passed
    }
}

// MARK: - Protocol

protocol UserProfileServiceProtocol: Sendable {
    func loadProfile() async throws -> UserProfile
    func saveProfile(_ profile: UserProfile) async throws
    func updateProgress(
        categoryId: String,
        categoryName: String,
        correct: Bool
    ) async throws -> UserProfile
    func recordExamAttempt(_ attempt: ExamAttempt) async throws -> UserProfile
    func updateExamDate(_ date: Date) async throws -> UserProfile
    func deleteProfile() async throws
}

// MARK: - Error

enum UserProfileServiceError: LocalizedError {
    case profileNotFound
    case saveFailed(String)
    case loadFailed(String)

    var errorDescription: String? {
        switch self {
        case .profileNotFound:
            return "User profile not found."
        case .saveFailed(let reason):
            return "Failed to save profile: \(reason)"
        case .loadFailed(let reason):
            return "Failed to load profile: \(reason)"
        }
    }
}

// MARK: - Implementation

@MainActor
final class UserProfileService: UserProfileServiceProtocol {
    private let defaults = UserDefaults.standard
    private let profileKey = "com.growmeldai.userprofile"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadProfile() async throws -> UserProfile {
        guard let data = defaults.data(forKey: profileKey) else {
            let newProfile = UserProfile()
            try await saveProfile(newProfile)
            return newProfile
        }
        do {
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            throw UserProfileServiceError.loadFailed(error.localizedDescription)
        }
    }

    func saveProfile(_ profile: UserProfile) async throws {
        do {
            let data = try encoder.encode(profile)
            defaults.set(data, forKey: profileKey)
        } catch {
            throw UserProfileServiceError.saveFailed(error.localizedDescription)
        }
    }

    func updateProgress(
        categoryId: String,
        categoryName: String,
        correct: Bool
    ) async throws -> UserProfile {
        var profile = try await loadProfile()
        var progress = profile.categoryProgress[categoryId] ?? CategoryProgress(
            categoryId: categoryId,
            categoryName: categoryName
        )
        progress.totalAnswered += 1
        if correct { progress.totalCorrect += 1 }
        profile.categoryProgress[categoryId] = progress
        profile.updatedAt = Date()
        try await saveProfile(profile)
        return profile
    }

    func recordExamAttempt(_ attempt: ExamAttempt) async throws -> UserProfile {
        var profile = try await loadProfile()
        profile.examAttempts.append(attempt)
        profile.updatedAt = Date()
        try await saveProfile(profile)
        return profile
    }

    func updateExamDate(_ date: Date) async throws -> UserProfile {
        var profile = try await loadProfile()
        profile.examDate = date
        profile.updatedAt = Date()
        try await saveProfile(profile)
        return profile
    }

    func deleteProfile() async throws {
        defaults.removeObject(forKey: profileKey)
    }
}