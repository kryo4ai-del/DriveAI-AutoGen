import Foundation
struct LocalQuestion: Codable {
    let id: String
    let question: String
    let answers: [String]
    let correctIndex: Int
    let explanation: String  // Official DACH content
    let category: String
    let difficulty: Int      // 1-5
    
    // Lightweight metadata for offline search
    let keywords: [String]
}

// Questions loaded from JSON bundle at runtime