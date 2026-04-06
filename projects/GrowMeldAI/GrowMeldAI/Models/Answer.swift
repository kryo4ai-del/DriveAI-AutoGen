import Foundation

struct Answer: Identifiable, Codable {
    let id: String
    let text: String
    let explanation: String // ✅ Required, always shown
}