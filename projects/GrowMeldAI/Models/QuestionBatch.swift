import Foundation
struct QuestionBatch: Codable {
    let lastUpdated: Date
    // But app never checks if data is stale
}