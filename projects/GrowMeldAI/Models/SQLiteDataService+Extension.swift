import Foundation

extension SQLiteDataService {
    func fetchQuestion(id: String) async throws -> GrowMeldQuestion {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let question = try self._fetchQuestion(id: id)
                    continuation.resume(returning: question)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchQuestions(in categoryID: String, limit: Int? = nil) async throws -> [GrowMeldQuestion] {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let questions = try self._fetchQuestions(in: categoryID, limit: limit)
                    continuation.resume(returning: questions)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func saveQuestion(_ question: GrowMeldQuestion) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try self._saveQuestion(question)
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}