// Services/ProgressService/ProgressServiceImpl.swift
@MainActor  // ✅ Enforce serial execution
class ProgressServiceImpl: ProgressService {
    private let repository: ProgressRepository
    private var pendingWrites: [String: Bool] = [:]
    
    func recordAnswer(questionId: String, correct: Bool) async throws {
        // Prevent duplicate simultaneous writes
        let key = "write_\(questionId)"
        guard pendingWrites[key] == nil else { return }
        
        pendingWrites[key] = true
        defer { pendingWrites.removeValue(forKey: key) }
        
        // Update and persist
        var progress = try await getProgress(categoryId: nil)
        progress.correctAnswers += correct ? 1 : 0
        progress.totalAnswered += 1
        
        try await repository.save(progress)
    }
}