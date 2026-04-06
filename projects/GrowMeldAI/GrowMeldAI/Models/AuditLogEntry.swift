import Foundation

struct AuditLogEntry: Identifiable, Codable {
    let id: UUID
    let eventType: String
    let timestamp: Date
    let metadata: [String: String]?
    let userConfirmed: Bool
    
    init(
        id: UUID = UUID(),
        eventType: String,
        timestamp: Date = Date(),
        metadata: [String: String]? = nil,
        userConfirmed: Bool = true
    ) {
        self.id = id
        self.eventType = eventType
        self.timestamp = timestamp
        self.metadata = metadata
        self.userConfirmed = userConfirmed
    }
    
    // MARK: - Event Type Helpers
    var germanDescription: String {
        switch eventType {
        case "consent_given":
            return "Zustimmung erteilt"
        case "consent_revoked":
            return "Zustimmung widerrufen"
        case "data_export_requested":
            return "Datenexport angefordert"
        case "data_deletion_initiated":
            return "Datenlöschung eingeleitet"
        case "data_deletion_completed":
            return "Datenlöschung abgeschlossen"
        default:
            return eventType
        }
    }
}