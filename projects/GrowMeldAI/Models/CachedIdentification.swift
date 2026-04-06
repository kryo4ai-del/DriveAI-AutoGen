import Foundation

struct IdentificationResult: Codable {
    let commonName: String
    let scientificName: String
    let confidence: Double
    let description: String
}

struct CachedIdentification: Codable {
    let imageHash: String
    let result: IdentificationResult
    let source: CacheSource
    let cachedAt: Date
    let expiresAt: Date

    var isExpired: Bool { Date() > expiresAt }
}

enum CacheSource: String, Codable {
    case api
    case offline
}