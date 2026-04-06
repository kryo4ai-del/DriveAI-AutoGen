// Services/Persistence/PerformanceDataService.swift

// GRDB Codable Support
extension QuestionAttempt: Codable, FetchableRecord, PersistableRecord {
    enum Columns: String, ColumnExpression {
        case id, questionID, categoryID, selectedAnswerIndex, correctAnswerIndex, timeSpentSeconds, timestamp, isCorrect
    }
}

extension ExamAttempt: Codable, FetchableRecord, PersistableRecord {
    enum Columns: String, ColumnExpression {
        case id, startTime, endTime, totalScore, maxScore, isPassed, categoryScoresJSON
    }
}