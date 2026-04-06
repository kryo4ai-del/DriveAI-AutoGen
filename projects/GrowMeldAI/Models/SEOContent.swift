import Foundation

// MARK: - Difficulty Level

enum DifficultyLevel: String, Codable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
}

// MARK: - Domain Models

struct SEOContent: Identifiable, Codable {
    let id: String
    let questionID: String
    let title: String
    let description: String
    let imageURL: String?
    let openGraphImage: String?
    let canonicalURL: String
    let keywords: [String]
    let category: String
    let difficulty: DifficultyLevel
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Metadata for Open Graph & Twitter Cards

struct MetadataModel: Codable {
    let ogTitle: String
    let ogDescription: String
    let ogImage: String?
    let ogType: String
    let twitterCard: TwitterCard
    let twitterCreator: String?
    let structuredData: StructuredDataSchema
    let locale: String

    enum TwitterCard: String, Codable {
        case summaryLarge = "summary_large_image"
        case summary = "summary"
    }
}

struct StructuredDataSchema: Codable {
    let type: String
    let name: String
    let description: String
    let image: String?
    let acceptedAnswer: String?
    let url: String
    let datePublished: Date
    let keywords: [String]
    let inLanguage: String

    func toJSONLD() -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let jsonData = try? encoder.encode(self),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }
}

// MARK: - Shareable Card (for social media)

struct ShareableQuestionCard: Identifiable, Codable {
    let id: String
    let questionID: String
    let title: String
    let category: String
    let difficulty: DifficultyLevel
    let metadata: MetadataModel
    let deepLink: String
    let shareableText: String?
    let createdAt: Date

    init(
        questionID: String,
        title: String,
        category: String,
        difficulty: DifficultyLevel,
        metadata: MetadataModel,
        deepLink: String,
        shareableText: String? = nil
    ) {
        self.id = UUID().uuidString
        self.questionID = questionID
        self.title = title
        self.category = category
        self.difficulty = difficulty
        self.metadata = metadata
        self.deepLink = deepLink
        self.shareableText = shareableText
        self.createdAt = Date()
    }
}