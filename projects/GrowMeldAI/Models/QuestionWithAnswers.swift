extension Question {
    static let answers = hasMany(
        Answer.self,
        using: ForeignKey(["question_id"])
    )
}

nonisolated func questions(
    forCategoryID categoryID: UUID,
    limit: Int? = nil
) async throws -> [Question] {
    try await dbQueue.read { db in
        var query = Question
            .including(all: Question.answers)  // ← Load answers
            .where(Column("category_id") == categoryID.uuidString)
        
        if let limit = limit {
            query = query.limit(limit)
        }
        
        let rows = try query.fetchAll(db)
        return rows.map { row in
            var question = row.question
            question.answers = row.answers
            return question
        }
    }
}

// Define association result struct:
struct QuestionWithAnswers: Decodable, FetchableRecord {
    var question: Question
    var answers: [Answer]
}