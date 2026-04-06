// Services/AuditService.swift

actor AuditService {
    static let shared = AuditService()
    
    private let database: AuditDatabase
    
    enum AuditEvent {
        case ageVerificationAttempted(year: Int, jurisdiction: String, succeeded: Bool)
        case parentalConsentEmailSent(email: String)
        case parentalConsentVerified(email: String)
        case consentDecisionRecorded(analyticsAllowed: Bool, marketingAllowed: Bool)
        case dataCollectionEvent(eventType: String, jurisdiction: String, userAge: String)
        case dataDeleted(reason: String, recordsAffected: Int)
        case userDataExported(format: String)
    }
    
    func log(event: AuditEvent) async throws {
        let record = AuditRecord(
            timestamp: Date(),
            event: event,
            userId: getCurrentUserId(),
            ipAddress: try? await getClientIPAddress()
        )
        
        try await database.insert(record)
    }
    
    func exportAuditLog(format: String = "json") async throws -> Data {
        let records = try await database.fetchAll()
        return try JSONEncoder().encode(records)
    }
}

struct AuditRecord: Codable {
    let timestamp: Date
    let event: String  // JSON-encoded event
    let userId: String
    let ipAddress: String?
}