import Foundation

struct CompetitorSnapshot: Identifiable, Codable, Hashable {
    let id: String
    let appName: String
    let appStoreID: String
    let category: String
    let currentRating: Double // 0.0–5.0
    let reviewCount: Int
    let downloadEstimate: Int?
    let version: String
    let lastUpdated: Date
    let ratingHistory: [RatingSnapshot]
    let sharedKeywords: [String]
    
    var ratingChangeFromMonthAgo: Double {
        guard ratingHistory.count > 30 else { return 0.0 }
        return ratingHistory[0].rating - ratingHistory[min(29, ratingHistory.count - 1)].rating
    }
}

struct RatingSnapshot: Codable, Hashable {
    let rating: Double
    let reviewCount: Int
    let date: Date
}