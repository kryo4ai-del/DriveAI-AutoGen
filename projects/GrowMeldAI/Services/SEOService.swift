import Foundation
import os.log

// MARK: - SEO Models

struct SEOContent: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let keywords: [String]
    let createdAt: Date
}

enum TwitterCard: String, Codable {
    case summary
    case summaryLarge = "summary_large_image"
}

struct StructuredDataSchema: Codable {
    let type: String
    let name: String
    let description: String
    let image: String
    let acceptedAnswer: String
    let url: URL
    let datePublished: Date
    let keywords: [String]
    let inLanguage: String
}

struct MetadataModel: Codable {
    let ogTitle: String
    let ogDescription: String
    let ogImage: URL?
    let ogType: String
    let twitterCard: TwitterCard
    let twitterCreator: String
    let structuredData: StructuredDataSchema
    let locale: String
}

struct ShareableQuestionCard: Codable, Identifiable {
    let id: String
    let questionID: String
    let title: String
    let category: String
    let difficulty: String
    let metadata: MetadataModel
    let deepLink: URL
    let shareableText: String

    init(questionID: String, title: String, category: String, difficulty: String,
         metadata: MetadataModel, deepLink: URL, shareableText: String) {
        self.id = UUID().uuidString
        self.questionID = questionID
        self.title = title
        self.category = category
        self.difficulty = difficulty
        self.metadata = metadata
        self.deepLink = deepLink
        self.shareableText = shareableText
    }
}

// MARK: - Question Model (local stub if not defined elsewhere)

struct Question: Codable, Identifiable {
    let id: String
    let text: String
    let category: String
    let difficulty: String
    let correctAnswer: String
    let options: [String]
}

// MARK: - LocalDataService (local stub if not defined elsewhere)

class LocalDataService {
    func fetchQuestions() -> [Question] { return [] }
}

// MARK: - SEOServiceError

enum SEOServiceError: LocalizedError {
    case encodingFailed(underlying: Error)
    case decodingFailed(underlying: Error)
    case fileNotFound(path: String)
    case cacheWriteFailed(underlying: Error)
    case invalidURL(string: String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .fileNotFound(let path):
            return "File not found at path: \(path)"
        case .cacheWriteFailed(let error):
            return "Cache write failed: \(error.localizedDescription)"
        case .invalidURL(let string):
            return "Invalid URL: \(string)"
        }
    }
}

// MARK: - SEO Service

@MainActor
final class SEOService: ObservableObject {
    @Published var shareableContent: [SEOContent] = []
    @Published var isLoading = false
    @Published var error: SEOServiceError?

    private let localDataService: LocalDataService
    private let logger = Logger(subsystem: "com.driveai.seo", category: "SEOService")
    private let fm = FileManager.default
    private let cacheDirectory: URL

    var dateProvider: () -> Date = { Date() }

    init(localDataService: LocalDataService) {
        self.localDataService = localDataService

        let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = cachePath.appendingPathComponent("SEOCache")

        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Metadata Generation

    func generateMetadata(for question: Question) -> MetadataModel {
        let baseURL = URL(string: "https://driveai.app")!
        let questionPath = baseURL
            .appendingPathComponent("question")
            .appendingPathComponent(question.id)

        let ogImagePath = "https://driveai.app/og/\(question.id).png"
        let ogImage = URL(string: ogImagePath)

        let description = generateDescription(for: question)
        let keywords = generateKeywords(for: question)

        return MetadataModel(
            ogTitle: "DriveAI: \(question.text)",
            ogDescription: description,
            ogImage: ogImage,
            ogType: "article",
            twitterCard: .summaryLarge,
            twitterCreator: "@DriveAI_DACH",
            structuredData: StructuredDataSchema(
                type: "Question",
                name: question.text,
                description: question.category,
                image: ogImagePath,
                acceptedAnswer: question.correctAnswer,
                url: questionPath,
                datePublished: dateProvider(),
                keywords: keywords,
                inLanguage: "de"
            ),
            locale: "de_DE"
        )
    }

    // MARK: - Shareable Card Creation

    func createShareableCard(for question: Question) -> ShareableQuestionCard {
        let metadata = generateMetadata(for: question)
        let deepLink = generateDeepLink(for: question)
        let shareText = generateShareText(for: question)

        let card = ShareableQuestionCard(
            questionID: question.id,
            title: question.text,
            category: question.category,
            difficulty: question.difficulty,
            metadata: metadata,
            deepLink: deepLink,
            shareableText: shareText
        )

        logger.debug("Created shareable card for question: \(question.id)")
        return card
    }

    func createShareableCards(for questions: [Question]) async throws -> [ShareableQuestionCard] {
        logger.debug("Creating \(questions.count) shareable cards")
        return questions.map { createShareableCard(for: $0) }
    }

    // MARK: - Cache Management

    func cacheCard(_ card: ShareableQuestionCard) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(card)
            let cacheFile = cacheDirectory.appendingPathComponent("\(card.id).json")
            try data.write(to: cacheFile)
            logger.debug("Cached card: \(card.id)")
        } catch {
            throw SEOServiceError.cacheWriteFailed(underlying: error)
        }
    }

    func retrieveCachedCard(id: String) throws -> ShareableQuestionCard? {
        let cacheFile = cacheDirectory.appendingPathComponent("\(id).json")

        guard fm.fileExists(atPath: cacheFile.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: cacheFile)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(ShareableQuestionCard.self, from: data)
        } catch {
            throw SEOServiceError.decodingFailed(underlying: error)
        }
    }

    func clearCache() throws {
        let contents = try fm.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for file in contents {
            try fm.removeItem(at: file)
        }
        logger.debug("Cache cleared")
    }

    // MARK: - Private Helpers

    private func generateDescription(for question: Question) -> String {
        return "Lerne die Antwort auf diese Führerscheinfrage: \(question.text). Kategorie: \(question.category)."
    }

    private func generateKeywords(for question: Question) -> [String] {
        return ["Führerschein", "Fahrschule", question.category, "DriveAI", "Theorie"]
    }

    private func generateDeepLink(for question: Question) -> URL {
        let urlString = "driveai://question/\(question.id)"
        return URL(string: urlString) ?? URL(string: "driveai://")!
    }

    private func generateShareText(for question: Question) -> String {
        return "Kannst du diese Führerscheinfrage beantworten? \(question.text) – Lerne mit DriveAI!"
    }
}