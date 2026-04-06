// ✅ Enforce at data layer, not just view layer
class ExamProgressRepository {
    private let currentUserID: UUID
    private let localDatabase: LocalDatabase
    
    init(currentUserID: UUID, localDatabase: LocalDatabase) {
        self.currentUserID = currentUserID
        self.localDatabase = localDatabase
    }
    
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
    
    private func isCurrentUserFamilyOwner() -> Bool {
        return false
    }
}

enum AccessControlError: Error {
    case unauthorized
}

struct ExamProgress {}

class LocalDatabase {
    func queryProgress(for userID: UUID) async throws -> ExamProgress {
        return ExamProgress()
    }
}

// Query layer always enforces access control
func exampleUsage() async throws {
    let repository = ExamProgressRepository(currentUserID: UUID(), localDatabase: LocalDatabase())
    let memberID = UUID()
    let progress = try await repository.getProgress(for: memberID)  // Throws if unauthorized
    _ = progress
}