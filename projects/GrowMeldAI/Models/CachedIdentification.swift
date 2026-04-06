import Foundation

struct CachedIdentification: Codable {
    let imageHash: String
    let result: PlantIdentificationResult
    let source: IdentificationCacheSource
    let cachedAt: Date
    let expiresAt: Date

    var isExpired: Bool { Date() > expiresAt }
}

struct PlantIdentificationResult: Codable {
    let plantName: String
    let confidence: Double
    let description: String
}

enum IdentificationCacheSource: String, Codable {
    case api
    case offline
}