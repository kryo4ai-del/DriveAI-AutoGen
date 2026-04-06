// DataDeletionService.swift – GDPR Article 17 implementation
protocol DataDeletionServiceProtocol {
    func deleteUserAccou(
        userId: String,
        reason: DeletionReason?
    ) async throws
    
    func deletionStatus(userId: String) async throws -> DeletionStatus
}

// Enum DeletionReason declared in Models/ComplianceRegion.swift
