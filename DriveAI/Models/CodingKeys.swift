extension SimulationResult {
    enum CodingKeys: String, CodingKey {
        case id, totalQuestions, correctAnswers, categoryScores, completedAt, durationSeconds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
        let correctAnswers = try container.decode(Int.self, forKey: .correctAnswers)
        let categoryScores = try container.decode([CategoryScore].self, forKey: .categoryScores)
        let completedAt = try container.decode(Date.self, forKey: .completedAt)
        let durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
        
        try self.init(
            id: id,
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            categoryScores: categoryScores,
            completedAt: completedAt,
            durationSeconds: durationSeconds
        )
    }
}