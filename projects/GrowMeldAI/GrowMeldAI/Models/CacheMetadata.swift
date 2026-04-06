import Foundation

struct CacheMetadata: Codable {
    let version: String
    let lastUpdated: Date
    let checksumSHA256: String
    let questionCount: Int
}
