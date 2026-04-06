import Foundation

struct KeywordMetric: Identifiable, Codable, Hashable {
    let id: UUID
    let word: String
    let currentRank: Int
    let searchVolume: Int
    let difficulty: Double // 0.0–1.0
    let trend: RankTrend
    let lastUpdated: Date
    let rankHistory: [RankSnapshot] // Last 30 days
    let estimatedMonthlyDownloads: Int?
    
    enum RankTrend: String, Codable {
        case up, down, stable
    }
    
    var isTracked: Bool { !rankHistory.isEmpty }
    var rankChangeFromWeekAgo: Int {
        guard rankHistory.count > 7 else { return 0 }
        return rankHistory[0].rank - rankHistory[7].rank
    }
}

struct RankSnapshot: Codable, Hashable {
    let rank: Int
    let date: Date
}