// MARK: - FeedbackPersistence.swift
import Foundation

final class LocalFeedbackStore: FeedbackPersistence {
    private let storage: FeedbackStorage
    private let retentionDays: Int

    init(storage: FeedbackStorage = UserDefaultsFeedbackStorage(),
         retentionDays: Int = 90) {
        self.storage = storage
        self.retentionDays = retentionDays
    }

    func saveFeedback(_ feedback: UserFeedback) async throws -> UUID {
        try await storage.save(feedback)
        return feedback.id
    }

    func fetchAllFeedback() async -> [UserFeedback] {
        await storage.loadAll()
    }

    func deleteFeedback(id: UUID) async throws {
        try await storage.delete(id: id)
    }

    func clearExpiredFeedback(olderThan: Date) async throws {
        let allFeedback = await storage.loadAll()
        let expired = allFeedback.filter { $0.timestamp < olderThan }
        try await withThrowingTaskGroup(of: Void.self) { group in
            for feedback in expired {
                group.addTask {
                    try await self.storage.delete(id: feedback.id)
                }
            }
        }
    }

    func count() async throws -> Int {
        await storage.count()
    }
}

// MARK: - Storage Backend

protocol FeedbackStorage {
    func save(_ feedback: UserFeedback) async throws
    func loadAll() async -> [UserFeedback]
    func delete(id: UUID) async throws
    func count() async -> Int
}

final class UserDefaultsFeedbackStorage: FeedbackStorage {
    private enum Keys {
        static let feedbacks = "driveai.feedback.feedbacks"
    }

    private let queue = DispatchQueue(label: "com.driveai.feedback.storage", qos: .utility)

    func save(_ feedback: UserFeedback) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    var existing: [Data] = UserDefaults.standard.array(forKey: Keys.feedbacks) as? [Data] ?? []
                    let encoded = try JSONEncoder().encode(feedback)
                    existing.append(encoded)
                    UserDefaults.standard.set(existing, forKey: Keys.feedbacks)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func loadAll() async -> [UserFeedback] {
        await withCheckedContinuation { continuation in
            queue.async {
                let dataArray = UserDefaults.standard.array(forKey: Keys.feedbacks) as? [Data] ?? []
                let feedbacks = dataArray.compactMap { data -> UserFeedback? in
                    try? JSONDecoder().decode(UserFeedback.self, from: data)
                }
                continuation.resume(returning: feedbacks)
            }
        }
    }

    func delete(id: UUID) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    var existing: [Data] = UserDefaults.standard.array(forKey: Keys.feedbacks) as? [Data] ?? []
                    existing.removeAll { data in
                        guard let feedback = try? JSONDecoder().decode(UserFeedback.self, from: data) else {
                            return false
                        }
                        return feedback.id == id
                    }
                    UserDefaults.standard.set(existing, forKey: Keys.feedbacks)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func count() async -> Int {
        await withCheckedContinuation { continuation in
            queue.async {
                let dataArray = UserDefaults.standard.array(forKey: Keys.feedbacks) as? [Data] ?? []
                continuation.resume(returning: dataArray.count)
            }
        }
    }
}