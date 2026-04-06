import Foundation

struct CacheMetadata: Codable {
    let version: String  // e.g., "2024.Q2"
    let lastUpdated: Date
    let checksumSHA256: String
    let questionCount: Int
}