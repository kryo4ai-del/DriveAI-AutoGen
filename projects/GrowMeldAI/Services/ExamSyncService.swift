import Foundation

// MARK: - Supporting Types

struct SyncResponse: Codable {
    let success: Bool
    let message: String
    let syncedAt: Date
}

struct UserProgress: Codable {
    let totalQuestionsAnswered: Int
    let correctAnswers: Int
    let categoryScores: [String: Double]
    let lastSyncedAt: Date
}

// MARK: - Protocol

protocol ExamSyncService: AnyObject {
    func submitExamResult(_ result: ExamResult) async throws -> SyncResponse
    func fetchProgressUpdate() async throws -> UserProgress
    func deleteLocalResult(_ id: UUID) async throws
}

// MARK: - Mock for Testing

class MockExamSyncService: ExamSyncService {
    var submitResultStub: (ExamResult) async throws -> SyncResponse = { _ in
        SyncResponse(
            success: true,
            message: "Erfolgreich synchronisiert",
            syncedAt: Date()
        )
    }

    var progressStub: () async throws -> UserProgress = {
        UserProgress(
            totalQuestionsAnswered: 150,
            correctAnswers: 120,
            categoryScores: [:],
            lastSyncedAt: Date()
        )
    }

    func submitExamResult(_ result: ExamResult) async throws -> SyncResponse {
        try await submitResultStub(result)
    }

    func fetchProgressUpdate() async throws -> UserProgress {
        try await progressStub()
    }

    func deleteLocalResult(_ id: UUID) async throws {
        // No-op for testing
    }
}