private func decodeQuestion(from row: Row) throws -> Question {
    let optionsJSON = row[self.options]
    
    // ✅ Explicit error handling with context
    guard let optionsData = optionsJSON.data(using: .utf8) else {
        throw QuestionDecodeError.invalidJSON(questionId: row[self.id], raw: optionsJSON)
    }
    
    do {
        let options = try JSONDecoder().decode([String].self, from: optionsData)
        return Question(
            id: row[self.id],
            categoryId: row[self.categoryId],
            text: row[self.text],
            options: options,
            correctIndex: row[self.correctIndex],
            explanation: row[self.explanation],
            difficulty: Question.Difficulty(rawValue: row[self.difficulty]) ?? .medium
        )
    } catch let DecodingError.dataCorrupted(context) {
        throw QuestionDecodeError.corruptedData(
            questionId: row[self.id],
            underlying: context.debugDescription
        )
    }
}

enum QuestionDecodeError: Error, LocalizedError {
    case invalidJSON(questionId: Int, raw: String)
    case corruptedData(questionId: Int, underlying: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidJSON(let id, let raw):
            return "Question \(id) has invalid JSON options: \(raw)"
        case .corruptedData(let id, let desc):
            return "Question \(id) data corrupted: \(desc)"
        }
    }
}