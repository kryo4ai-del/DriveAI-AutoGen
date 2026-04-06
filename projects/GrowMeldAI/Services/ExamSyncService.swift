import Foundation

// MARK: - Protocol

protocol ExamSyncService: AnyObject {
    func submitExamResult(_ result: ExamResult) async throws -> SyncResponse
    func fetchProgressUpdate() async throws -> UserProgress
    func deleteLocalResult(_ id: UUID) async throws
}

// MARK: - Firebase Implementation

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