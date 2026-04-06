import Foundation

struct EventPayload: Codable {
    let type: String
    let data: [String: String]
}
