import Foundation

struct ConsentLog: Codable, Identifiable {
    let id: UUID
    let consentType: String
    let granted: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), consentType: String, granted: Bool, timestamp: Date = Date()) {
        self.id = id
        self.consentType = consentType
        self.granted = granted
        self.timestamp = timestamp
    }
}
