struct Exercise: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let category: ExerciseCategory
    let difficulty: Difficulty
    let estimatedDuration: TimeInterval
    let questionCount: Int
    
    enum Difficulty: String, Codable, Comparable, Sendable, CaseIterable {
        case beginner, intermediate, advanced
    }
}