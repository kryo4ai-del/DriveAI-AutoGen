import Foundation

struct Quiz: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let category: LicenseType
    let difficulty: Difficulty
    let topicArea: TopicArea
    let questionCount: Int
    let estimatedDurationSeconds: TimeInterval
    let description: String
    let questions: [Question]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Quiz, rhs: Quiz) -> Bool {
        lhs.id == rhs.id
    }
}