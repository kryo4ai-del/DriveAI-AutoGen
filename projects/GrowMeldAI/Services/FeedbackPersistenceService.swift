import Foundation

protocol FeedbackPersistenceService: AnyObject {
    func save(_ feedback: UserFeedback) async throws
    func fetch(for questionID: UUID) async throws -> [UserFeedback]
    func updateStatus(_ id: UUID, to status: FeedbackStatus) async throws
    func flag(_ questionID: UUID) async throws
    func unflag(_ questionID: UUID) async throws
}

/// LocalDataService handles persistence (SQLite/JSON)