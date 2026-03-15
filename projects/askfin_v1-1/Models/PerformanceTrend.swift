import Foundation

struct PerformanceTrend: Identifiable, Codable {
    let id: UUID
    let categoryId: String
    let categoryName: String
    let dataPoints: [TrendPoint]
    let trend: TrendDirection
    
    enum TrendDirection: String, Codable {
        case improving
        case declining
        case stable
        
        var symbol: String {
            switch self {
            case .improving: return "📈"
            case .declining: return "📉"
            case .stable: return "➡️"
            }
        }
        
        var accessibilityLabel: String {
            switch self {
            case .improving: return "Performance improving"
            case .declining: return "Performance declining"
            case .stable: return "Performance stable"
            }
        }
    }
    
    var averageScore: Double {
        guard !dataPoints.isEmpty else { return 0 }
        return dataPoints.map { $0.score }.reduce(0, +) / Double(dataPoints.count)
    }
    
    var recentScore: Double {
        dataPoints.last?.score ?? 0
    }
    
    var velocityPercentage: Double {
        guard dataPoints.count >= 2 else { return 0 }
        let first = dataPoints.first!.score
        let last = dataPoints.last!.score
        return last - first
    }
}

struct TrendPoint: Codable {
    let score: Double
    let date: Date
    let questionCount: Int
}