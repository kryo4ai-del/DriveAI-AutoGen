import Foundation

struct CachedCard: Codable {
    let card: ShareableQuestionCard
    let cachedAt: Date
    let ttl: TimeInterval

    var isExpired: Bool {
        Date().timeIntervalSince(cachedAt) > ttl
    }
}