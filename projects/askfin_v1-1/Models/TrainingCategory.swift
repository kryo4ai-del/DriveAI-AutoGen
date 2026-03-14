import Foundation

struct TrainingCategory: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String?
    let questionCount: Int
    let iconName: String
    
    // Session stats
    var attemptCount: Int = 0
    var bestScore: Int = 0
    var lastAttemptDate: Date?
    
    var displayScore: String {
        bestScore > 0 ? "\(bestScore)%" : "—"
    }
}