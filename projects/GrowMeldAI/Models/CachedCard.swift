struct CachedCard: Codable {
    let card: ShareableQuestionCard
    let cachedAt: Date
    let ttl: TimeInterval  // 24 hours default
    
    var isExpired: Bool {
        Date().timeIntervalSince(cachedAt) > ttl
    }
}

func cacheCard(_ card: ShareableQuestionCard, ttl: TimeInterval = 86400) {
    Task.detached(priority: .background) { [weak self] in
        guard let self = self else { return }
        
        let cached = CachedCard(card: card, cachedAt: Date(), ttl: ttl)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(cached)
            let cacheFile = self.cacheDirectory.appendingPathComponent("\(card.id).json")
            try data.write(to: cacheFile, options: .atomic)
        } catch {
            self.logger.warning("Cache write failed: \(error)")
        }
    }
}

func retrieveCachedCard(id: String) -> ShareableQuestionCard? {
    // ... existing code ...
    
    if cached.isExpired {
        try? fileManager.removeItem(at: cacheFile)
        return nil  // Force regeneration
    }
    
    return cached.card
}