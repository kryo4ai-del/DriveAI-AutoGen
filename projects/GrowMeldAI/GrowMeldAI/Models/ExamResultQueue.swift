// LocalQueueService.swift
class ExamResultQueue {
    func enqueue(_ result: ExamResult) throws {
        try LocalDataService.shared.saveExamResult(result)
        // Mark as "pending sync"
    }
    
    func flushPendingResults() async throws {
        let pending = try LocalDataService.shared.fetchPendingExamResults()
        for result in pending {
            try await dataSyncService.uploadExamResult(result)
        }
    }
}