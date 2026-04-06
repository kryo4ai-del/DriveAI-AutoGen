final class UserProgressServiceImpl: UserProgressService {
    private var progressCache: [String: QuestionProgress] = [:]
    private let queue = DispatchQueue(
        label: "com.driveai.progress",
        attributes: .concurrent
    )
    
    func saveProgress(_ progress: QuestionProgress) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) { [weak self] in  // Exclusive write
                do {
                    self?.progressCache[progress.questionId] = progress
                    let encoded = try JSONEncoder()
                        .encode(self?.progressCache.values.map { $0 } ?? [])
                    try encoded.write(to: self!.progressPath, options: .atomic)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func loadProgress(questionId: String) -> QuestionProgress? {
        var result: QuestionProgress?
        queue.sync {  // Concurrent read
            result = progressCache[questionId]
        }
        return result
    }
}