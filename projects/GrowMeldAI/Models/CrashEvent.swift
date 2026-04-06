import Foundation

struct CrashEvent: Codable {
    let id: String
    let timestamp: Date
    let reason: String
    let stackTrace: String

    init(id: String = UUID().uuidString,
         timestamp: Date = Date(),
         reason: String,
         stackTrace: String = "") {
        self.id = id
        self.timestamp = timestamp
        self.reason = reason
        self.stackTrace = stackTrace
    }
}

private let queue: DispatchQueue = DispatchQueue(label: "com.growmeldai.crashevent.queue")