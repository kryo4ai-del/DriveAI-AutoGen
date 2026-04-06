import Foundation

// SQLite DTO — mirrors database schema exactly
struct QuestionEntity: Codable {
    let id: Int
    let categoryId: Int
    let text: String
    let options: String // JSON array stored as text
    let correctAnswerIndex: Int
    let explanation: String
    let imageUrl: String?
    let difficulty: String
    let lastUpdated: Int // Unix timestamp
    
    func toDomain() throws -> Question {
        let optionsData = options.data(using: .utf8) ?? Data()
        let parsedOptions = try JSONDecoder().decode([String].self, from: optionsData)
        
        return Question(
            id: id,
            categoryId: categoryId,
            text: text,
            options: parsedOptions,
            correctAnswerIndex: correctAnswerIndex,
            explanation: explanation,
            imageUrl: imageUrl,
            difficulty: Question.DifficultyLevel(rawValue: difficulty) ?? .medium,
            lastUpdated: Date(timeIntervalSince1970: TimeInterval(lastUpdated))
        )
    }
}

struct CategoryEntity: Codable {
    let id: Int
    let name: String
    let description: String
    let iconName: String
    let questionCount: Int
    
    func toDomain() -> Category {
        Category(
            id: id,
            name: name,
            description: description,
            iconName: iconName,
            questionCount: questionCount
        )
    }
}

struct SyncMetadata: Codable {
    let lastSyncDate: Date
    let catalogVersion: String
    let questionCountHash: String
    
    static let filename = "sync_metadata.json"
}