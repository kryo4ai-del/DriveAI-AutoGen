class MockDataSync: DataSyncService {
    func uploadExamResult(_ result: ExamResult) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000)
    }
}