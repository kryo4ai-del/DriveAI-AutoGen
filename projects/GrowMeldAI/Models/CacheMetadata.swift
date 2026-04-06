struct CacheMetadata: Codable {
    let version: String  // e.g., "2024.Q2"
    let lastUpdated: Date
    let checksumSHA256: String
    let questionCount: Int
}

extension LocalDataService {
    func shouldUpdateQuestions() async throws -> Bool {
        let remote = try await fetchRemoteCatalogMetadata()
        let local = try fetchLocalCacheMetadata()
        return remote.version > local.version
    }
}