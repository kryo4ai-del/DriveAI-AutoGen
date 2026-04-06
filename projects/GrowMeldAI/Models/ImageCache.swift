// Services/Domain/Protocols/ImageCache.swift
protocol ImageCache {
  func get(for imageHash: String) async -> CachedIdentification?
  func save(_ result: CachedIdentification) async throws
  func clear(olderThan: Date) async throws
}

// Models/CachedIdentification.swift
struct CachedIdentification: Codable {
  let imageHash: String // SHA256(imageData)
  let result: IdentificationResult
  let source: CacheSource // .api or .offline
  let cachedAt: Date
  let expiresAt: Date
  
  var isExpired: Bool { Date() > expiresAt }
}

enum CacheSource: String, Codable {
  case api       // Fresh from Plant.id
  case offline   // Fallback when network unavailable
}