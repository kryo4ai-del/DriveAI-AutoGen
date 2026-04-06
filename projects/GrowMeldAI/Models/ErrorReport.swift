import Foundation

public struct ErrorReport: Codable, Identifiable {
    public let id: String
    public let message: String
    public let context: [String: String]
    public let timestamp: Date

    public init(id: String = UUID().uuidString, message: String, context: [String: String] = [:], timestamp: Date = Date()) {
        self.id = id
        self.message = message
        self.context = context
        self.timestamp = timestamp
    }
}