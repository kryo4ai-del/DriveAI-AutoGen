struct CachedShareableCard: Codable {
    let card: ShareableQuestionCard
    let cachedAt: Date
    let expiresAt: Date
    
    var isExpired: Bool {
        Date() > expiresAt
    }
    
    init(card: ShareableQuestionCard, ttl: TimeInterval = 86400) { // 24 hours
        self.card = card
        self.cachedAt = Date()
        self.expiresAt = Date().addingTimeInterval(ttl)
    }
}

func retrieveCachedCard(id: String) throws -> ShareableQuestionCard? {
    let cacheFile = cacheDirectory.appendingPathComponent("\(id).json")
    
    guard fileManager.fileExists(atPath: cacheFile.path) else {
        return nil
    }
    
    let data = try Data(contentsOf: cacheFile)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let cachedCard = try decoder.decode(CachedShareableCard.self, from: data)
    
    // Return nil if expired
    if cachedCard.isExpired {
        try fileManager.removeItem(at: cacheFile)
        return nil
    }
    
    return cachedCard.card
}