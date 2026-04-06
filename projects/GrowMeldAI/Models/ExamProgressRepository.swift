// ✅ Enforce at data layer, not just view layer
class ExamProgressRepository {
    private let currentUserID: UUID
    
    func getProgress(for userID: UUID) async throws -> ExamProgress {
        // Check authorization FIRST, before any DB query
        guard canAccess(userID) else {
            throw AccessControlError.unauthorized
        }
        return try await localDatabase.queryProgress(for: userID)
    }
    
    private func canAccess(_ targetUserID: UUID) -> Bool {
        // Only owner can view others' progress
        return currentUserID == targetUserID || isCurrentUserFamilyOwner()
    }
}

// Query layer always enforces access control
let progress = try await repository.getProgress(for: memberID)  // Throws if unauthorized