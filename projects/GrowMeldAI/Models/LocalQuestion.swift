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

// Stored as JSON bundle: ~4MB for ~1400 DACH questions
let questions = Bundle.main.decode([LocalQuestion].self, from: "question_catalog.json")