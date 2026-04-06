import Foundation

struct CrashEvent: Codable {
    let id: UUID
    let message: String
    let timestamp: Date
    init(id: UUID = UUID(), message: String, timestamp: Date = Date()) {
        self.id = id; self.message = message; self.timestamp = timestamp
    }
}
