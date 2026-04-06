struct Question {
    let id: String
    let categoryId: String
    let answers: [String]

    init(row: Row) throws {
        guard let id = row["questionId"] as? String else {
            throw DatabaseError.invalidQuestion("Missing questionId")
        }
        guard let categoryId = row["categoryId"] as? String else {
            throw DatabaseError.invalidQuestion("Missing categoryId")
        }

        let answersJson = row["answersJson"] as? String ?? "[]"
        guard let answersData = answersJson.data(using: .utf8) else {
            throw DatabaseError.corruptedData("Invalid JSON encoding")
        }

        self.id = id
        self.categoryId = categoryId
        self.answers = try JSONDecoder().decode([String].self, from: answersData)
        // ...
    }
}

typealias Row = [String: Any]

enum DatabaseError: LocalizedError {
    case invalidQuestion(String)
    case corruptedData(String)

    var errorDescription: String? {
        switch self {
        case .invalidQuestion(let message):
            return message
        case .corruptedData(let message):
            return message
        }
    }
}