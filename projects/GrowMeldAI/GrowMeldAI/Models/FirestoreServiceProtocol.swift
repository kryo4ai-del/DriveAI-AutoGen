// Models/FirestoreServiceProtocol.swift

import Foundation

// MARK: - Supporting Types

struct GrowMeldUserProfile: Codable, Identifiable {
    let id: String
    var displayName: String
    var email: String
    var avatarURL: URL?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        displayName: String,
        email: String,
        avatarURL: URL? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct GrowMeldCategoryProgress: Codable, Identifiable {
    let id: String
    let categoryId: String
    var correctAnswers: Int
    var totalAnswers: Int
    var lastAttemptedAt: Date?

    var completionRate: Double {
        guard totalAnswers > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalAnswers)
    }

    init(
        id: String = UUID().uuidString,
        categoryId: String,
        correctAnswers: Int = 0,
        totalAnswers: Int = 0,
        lastAttemptedAt: Date? = nil
    ) {
        self.id = id
        self.categoryId = categoryId
        self.correctAnswers = correctAnswers
        self.totalAnswers = totalAnswers
        self.lastAttemptedAt = lastAttemptedAt
    }
}

struct GrowMeldExamResult: Codable, Identifiable {
    let id: String
    let score: Double
    let totalQuestions: Int
    let correctAnswers: Int
    let duration: TimeInterval
    let completedAt: Date

    init(
        id: String = UUID().uuidString,
        score: Double,
        totalQuestions: Int,
        correctAnswers: Int,
        duration: TimeInterval,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.score = score
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.duration = duration
        self.completedAt = completedAt
    }
}

struct QuestionAnswer: Codable, Identifiable {
    let id: String
    let questionId: String
    let categoryId: String
    let selectedAnswerId: String
    let isCorrect: Bool
    let answeredAt: Date

    init(
        id: String = UUID().uuidString,
        questionId: String,
        categoryId: String,
        selectedAnswerId: String,
        isCorrect: Bool,
        answeredAt: Date = Date()
    ) {
        self.id = id
        self.questionId = questionId
        self.categoryId = categoryId
        self.selectedAnswerId = selectedAnswerId
        self.isCorrect = isCorrect
        self.answeredAt = answeredAt
    }
}

struct ExamRecord: Codable, Identifiable {
    let id: String
    let result: GrowMeldExamResult
    let notes: String?
    let recordedAt: Date

    init(
        id: String = UUID().uuidString,
        result: GrowMeldExamResult,
        notes: String? = nil,
        recordedAt: Date = Date()
    ) {
        self.id = id
        self.result = result
        self.notes = notes
        self.recordedAt = recordedAt
    }
}

/// Opaque token returned by observer registration, allowing the caller to cancel listening.
final class ListenerRegistration {
    private let cancelHandler: () -> Void

    init(cancelHandler: @escaping () -> Void) {
        self.cancelHandler = cancelHandler
    }

    func remove() {
        cancelHandler()
    }
}

// MARK: - Protocol

protocol FirestoreServiceProtocol: AnyObject {
    // User Profile
    func fetchUserProfile() async throws -> GrowMeldUserProfile
    func updateUserProfile(_ profile: GrowMeldUserProfile) async throws

    // Progress Tracking
    func logQuestionAnswer(_ answer: QuestionAnswer) async throws
    func fetchProgressForCategory(_ categoryId: String) async throws -> GrowMeldCategoryProgress
    func syncAllProgress() async throws

    // Exam History
    func logExamResult(_ result: GrowMeldExamResult) async throws
    func fetchExamHistory() async throws -> [ExamRecord]

    // Real-time listeners
    func observeProgress(categoryId: String, handler: @escaping ([GrowMeldCategoryProgress]) -> Void) -> ListenerRegistration?
}

// MARK: - Local / Offline Implementation

final class LocalFirestoreService: FirestoreServiceProtocol {

    // MARK: - Private Storage

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var progressListeners: [String: ([GrowMeldCategoryProgress]) -> Void] = [:]

    // MARK: - Keys

    private enum StorageKey {
        static let userProfile = "local_firestore_user_profile"
        static let questionAnswers = "local_firestore_question_answers"
        static let categoryProgress = "local_firestore_category_progress"
        static let examResults = "local_firestore_exam_results"
        static let examHistory = "local_firestore_exam_history"
    }

    // MARK: - User Profile

    func fetchUserProfile() async throws -> GrowMeldUserProfile {
        guard
            let data = defaults.data(forKey: StorageKey.userProfile),
            let profile = try? decoder.decode(GrowMeldUserProfile.self, from: data)
        else {
            let defaultProfile = GrowMeldUserProfile(
                displayName: "Guest User",
                email: "guest@growmeld.app"
            )
            return defaultProfile
        }
        return profile
    }

    func updateUserProfile(_ profile: GrowMeldUserProfile) async throws {
        let data = try encoder.encode(profile)
        defaults.set(data, forKey: StorageKey.userProfile)
    }

    // MARK: - Progress Tracking

    func logQuestionAnswer(_ answer: QuestionAnswer) async throws {
        var answers = loadAnswers()
        answers.append(answer)
        let data = try encoder.encode(answers)
        defaults.set(data, forKey: StorageKey.questionAnswers)

        // Update category progress
        var progress = try await fetchProgressForCategory(answer.categoryId)
        progress = GrowMeldCategoryProgress(
            id: progress.id,
            categoryId: answer.categoryId,
            correctAnswers: progress.correctAnswers + (answer.isCorrect ? 1 : 0),
            totalAnswers: progress.totalAnswers + 1,
            lastAttemptedAt: answer.answeredAt
        )
        try await saveProgress(progress)

        // Notify listeners
        notifyListeners(for: answer.categoryId)
    }

    func fetchProgressForCategory(_ categoryId: String) async throws -> GrowMeldCategoryProgress {
        let allProgress = loadAllProgress()
        return allProgress.first { $0.categoryId == categoryId }
            ?? GrowMeldCategoryProgress(categoryId: categoryId)
    }

    func syncAllProgress() async throws {
        // In local implementation, data is already persisted; no-op for sync.
    }

    // MARK: - Exam History

    func logExamResult(_ result: GrowMeldExamResult) async throws {
        let record = ExamRecord(result: result)
        var history = loadExamHistory()
        history.append(record)
        let data = try encoder.encode(history)
        defaults.set(data, forKey: StorageKey.examHistory)
    }

    func fetchExamHistory() async throws -> [ExamRecord] {
        return loadExamHistory()
    }

    // MARK: - Real-time Listeners

    func observeProgress(categoryId: String, handler: @escaping ([GrowMeldCategoryProgress]) -> Void) -> ListenerRegistration? {
        progressListeners[categoryId] = handler

        // Immediately emit current state
        let allProgress = loadAllProgress()
        let filtered = allProgress.filter { $0.categoryId == categoryId }
        handler(filtered)

        let registration = ListenerRegistration { [weak self] in
            self?.progressListeners.removeValue(forKey: categoryId)
        }
        return registration
    }

    // MARK: - Private Helpers

    private func loadAnswers() -> [QuestionAnswer] {
        guard
            let data = defaults.data(forKey: StorageKey.questionAnswers),
            let answers = try? decoder.decode([QuestionAnswer].self, from: data)
        else { return [] }
        return answers
    }

    private func loadAllProgress() -> [GrowMeldCategoryProgress] {
        guard
            let data = defaults.data(forKey: StorageKey.categoryProgress),
            let progress = try? decoder.decode([GrowMeldCategoryProgress].self, from: data)
        else { return [] }
        return progress
    }

    private func saveProgress(_ updated: GrowMeldCategoryProgress) async throws {
        var allProgress = loadAllProgress()
        if let index = allProgress.firstIndex(where: { $0.categoryId == updated.categoryId }) {
            allProgress[index] = updated
        } else {
            allProgress.append(updated)
        }
        let data = try encoder.encode(allProgress)
        defaults.set(data, forKey: StorageKey.categoryProgress)
    }

    private func loadExamHistory() -> [ExamRecord] {
        guard
            let data = defaults.data(forKey: StorageKey.examHistory),
            let history = try? decoder.decode([ExamRecord].self, from: data)
        else { return [] }
        return history
    }

    private func notifyListeners(for categoryId: String) {
        guard let handler = progressListeners[categoryId] else { return }
        let filtered = loadAllProgress().filter { $0.categoryId == categoryId }
        handler(filtered)
    }
}