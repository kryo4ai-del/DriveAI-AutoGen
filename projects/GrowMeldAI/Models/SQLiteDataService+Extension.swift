// Models/SQLiteDataService+Extension.swift
import Foundation

// GRDB is not available as a module in this target.
// This extension provides async wrappers around the synchronous SQLiteDataService API.

extension SQLiteDataService {
    /// Fetch a single question by ID using a background queue
    func fetchQuestion(id: String) async throws -> Question {
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

    /// Fetch questions in a category with an optional limit
    func fetchQuestions(in categoryID: String, limit: Int? = nil) async throws -> [Question] {
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

    /// Save (insert or update) a question using a background queue
    func saveQuestion(_ question: Question) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try self._saveQuestion(question)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}