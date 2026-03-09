import Foundation

struct User: Identifiable {
    var id = UUID()
    var examDate: Date
    var score: Int = 0  // Default score initialized to zero
    
    mutating func updateScore(to newScore: Int) {
        score = newScore
    }
}