struct CachePolicy {
    static let questionsTTL: TimeInterval = 86400     // 24 hours
    static let progressTTL: TimeInterval = 300        // 5 minutes
    static let profileTTL: TimeInterval = 3600        // 1 hour
}

await cacheManager.set(result, for: key, ttl: CachePolicy.questionsTTL)