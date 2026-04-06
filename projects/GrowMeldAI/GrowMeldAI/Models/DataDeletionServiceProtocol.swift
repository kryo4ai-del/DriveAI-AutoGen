// DataDeletionService.swift – GDPR Article 17 implementation
protocol DataDeletionServiceProtocol {
    func deleteUserAccount(
        userId: String,
        reason: DeletionReason?
    ) async throws
    
    func deletionStatus(userId: String) async throws -> DeletionStatus
}

enum DeletionReason {
    case userRequested
    case accountInactive(days: Int) // Auto-delete after 12 months
    case parentRequest // Parental control
}
