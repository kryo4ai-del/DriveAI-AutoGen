struct QuestionRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var text: String
    var options: [String] // JSON encoded
    var correctAnswer: Int
    var categoryID: String
    var explanation: String?
    
    static let tableName = "questions"
}

struct ProgressRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var categoryID: String
    var questionsAttempted: Int
    var correctAnswers: Int
    var lastAttempted: Date
    var streak: Int
    
    static let tableName = "user_progress"
}