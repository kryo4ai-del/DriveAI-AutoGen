// DataBackend.swift
import Foundation

enum BackendType: String, CaseIterable, Identifiable {
    case local
    case firebase
    case iCloud

    var id: String { rawValue }
}

struct UserStatistics: Codable {
    let totalQuestionsAttempted: Int
    let correctAnswers: Int
    let incorrectAnswers: Int
    let averageResponseTime: TimeInterval
    let lastActiveDate: Date
}

struct QuestionAttempt: Codable, Identifiable {
    let id = UUID()
    let questionId: String
    let selectedAnswerId: String?
    let isCorrect: Bool
    let timestamp: Date
}

final class FirebaseDataService: DataBackend {
    private let networkService: NetworkService
    private let authService: AuthService
    private var activeBackend: BackendType = .local

    init(networkService: NetworkService, authService: AuthService) {
        self.networkService = networkService
        self.authService = authService
    }

    func syncProgress(category: String) async throws {
        guard authService.isAuthenticated else {
            throw FirebaseError.notAuthenticated
        }

        let localProgress = try await fetchLocalProgress(category: category)
        try await networkService.uploadProgress(localProgress, category: category)
    }

    func fetchStatistics() async throws -> UserStatistics {
        guard authService.isAuthenticated else {
            throw FirebaseError.notAuthenticated
        }

        return try await networkService.fetchStatistics()
    }

    func uploadAttempt(_ attempt: QuestionAttempt) async throws {
        guard authService.isAuthenticated else {
            throw FirebaseError.notAuthenticated
        }

        try await networkService.uploadAttempt(attempt)
    }

    func getAvailableBackends() -> [BackendType] {
        BackendType.allCases
    }

    func setActiveBackend(_ backend: BackendType) async {
        activeBackend = backend
    }

    func getActiveBackend() async -> BackendType {
        activeBackend
    }

    // MARK: - Private Methods
    private func fetchLocalProgress(category: String) async throws -> UserProgress {
        // Implementation would fetch from local storage
        return UserProgress(category: category, questions: [])
    }
}

enum FirebaseError: Error {
    case notAuthenticated
    case networkError(Error)
    case dataCorruption
    case quotaExceeded
}
