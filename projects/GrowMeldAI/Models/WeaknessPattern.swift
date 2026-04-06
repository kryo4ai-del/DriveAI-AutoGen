import Foundation

/// Identifies learning gaps and recovery patterns
struct WeaknessPattern: Codable, Sendable, Identifiable {
    let id = UUID()
    let categoryID: UUID
    let categoryName: String
    let errorRate: Double
    let lastErrorDate: Date
    let errorFrequency: [Date]  // Last 5-10 errors
    let recoveryTime: TimeInterval?  // Time to reach >80% after weakness detected
    let recommendedFocusLevel: FocusLevel
    let questionsUnansweredCorrectly: Int
    
    var isCritical: Bool {
        errorRate > 0.35
    }
    
    var averageErrorSpacing: TimeInterval {
        guard errorFrequency.count > 1 else { return 0 }
        let intervals = zip(errorFrequency, errorFrequency.dropFirst()).map {
            $0.1.timeIntervalSince($0.0)
        }
        return intervals.reduce(0, +) / Double(intervals.count)
    }
    
    var isImproving: Bool {
        guard errorFrequency.count >= 3 else { return false }
        let recentErrors = errorFrequency.suffix(3)
        let olderErrors = errorFrequency.dropLast(3).prefix(3)
        
        let recentSpacing = recentErrors.reduce(0) { acc, _ in acc + 1 } / 3.0
        let olderSpacing = olderErrors.reduce(0) { acc, _ in acc + 1 } / 3.0
        
        return recentSpacing > olderSpacing * 1.2  // 20% improvement
    }
}

enum FocusLevel: String, Codable, Sendable {
    case critical = "critical"    // >35% error
    case high = "high"            // 25-35%
    case moderate = "moderate"    // 15-25%
    case monitor = "monitor"      // <15% but trending down
}