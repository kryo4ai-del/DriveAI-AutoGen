import Foundation

enum DeletionReason {
    case userRequested
    case accountInactive(days: Int)
    case parentRequest
}

enum DeletionStatus {
    case pending
    case inProgress
    case completed
    case failed(Error)
}

protocol DataDeletionServiceProtocol {
    func deleteUserAccount(
        userId: String,
        reason: DeletionReason?
    ) async throws

    func deletionStatus(userId: String) async throws -> DeletionStatus
}