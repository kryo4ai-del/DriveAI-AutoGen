import Foundation

// MARK: - Domain Models

struct SEOContent: Identifiable, Codable {
    let id: String
    let questionID: String
    let title: String
    let description: String
    let imageURL: String?
    let openGraphImage: String?
    let canonicalURL: URL
    let keywords: [String]
    let category: String
    let difficulty: DifficultyLevel
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, questionID, title, description, imageURL, openGraphImage
        case canonicalURL, keywords, category, difficulty, createdAt, updatedAt
    }
}

// MARK: - Metadata for Open Graph & Twitter Cards

struct MetadataModel: Codable {
    let ogTitle: String
    let ogDescription: String
    let ogImage: URL?
    let ogType: String // "article", "website"
    let twitterCard: TwitterCard
    let twitterCreator: String?
    let structuredData: StructuredDataSchema
    let locale: String // "de_DE"
    
    enum TwitterCard: String, Codable {
        case summaryLarge = "summary_large_image"
        case summary = "summary"
    }
}

struct StructuredDataSchema: Codable {
    let type: String // "Question", "FAQPage"
    let name: String
    let description: String
    let image: String?
    let acceptedAnswer: String?
    let url: URL
    let datePublished: Date
    let keywords: [String]
    let inLanguage: String
    
    // JSON-LD serialization
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
    let deepLink: URL
    let shareableText: String?
    let createdAt: Date
    
    init(
        questionID: String,
        title: String,
        category: String,
        difficulty: DifficultyLevel,
        metadata: MetadataModel,
        deepLink: URL,
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

// MARK: - Analytics Event (for tracking shares)
