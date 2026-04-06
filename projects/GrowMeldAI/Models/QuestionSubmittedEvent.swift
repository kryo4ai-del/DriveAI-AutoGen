// DELETE the entire AnyCodable enum

// Use this instead:
struct QuestionSubmittedEvent: Codable {
    let type: String = "question_submitted"
    let questionId: String
    let remainingQuota: Int
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case type, questionId = "question_id", remainingQuota = "remaining_quota", timestamp
    }
}

// Usage:
let event = QuestionSubmittedEvent(
    questionId: questionId,
    remainingQuota: quota.remainingToday,
    timestamp: Date()
)
try dataSource.appendEvent(event)