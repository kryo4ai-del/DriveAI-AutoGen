struct UserSessionStats: Codable {
    let exerciseId: UUID
    let completedCount: Int
    let averageScore: Double
    let lastAttemptDate: Date?
    let bestScore: Double
    
    enum CodingKeys: String, CodingKey {
        case exerciseId, completedCount, averageScore, bestScore
        case lastAttemptDate = "last_attempt_date"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(exerciseId, forKey: .exerciseId)
        try container.encode(lastAttemptDate?.ISO8601Format(), forKey: .lastAttemptDate)
    }
}