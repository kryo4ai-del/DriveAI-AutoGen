import Foundation

struct AuditEvent: Codable {
    let id: UUID
    let action: String
    let timestamp: Date
    init(action: String) {
        self.id = UUID()
        self.action = action
        self.timestamp = Date()
    }
}
