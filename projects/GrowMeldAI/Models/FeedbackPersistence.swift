import Foundation

/// Abstract persistence layer for feedback storage
protocol FeedbackPersistence: Sendable {
    /// Save feedback to storage
    func saveFeedback(_ feedback: UserFeedback) async throws -> UUID
    
    /// Retrieve all feedback items
    func fetchAllFeedback() async throws -> [UserFeedback]
    
    /// Delete feedback by ID
    func deleteFeedback(id: UUID) async throws
    
    /// Delete feedback older than specified date (90-day retention)
    func clearExpiredFeedback(olderThan: Date) async throws
    
    /// Count of pending feedback items
    func count() async throws -> Int
}