import Foundation
import os.log

// MARK: - SEO Service

@MainActor
class SEOService: ObservableObject {
    @Published var shareableContent: [SEOContent] = []
    @Published var isLoading = false
    @Published var error: SEOServiceError?
    
    private let localDataService: LocalDataService
    private let logger = Logger(subsystem: "com.driveai.seo", category: "SEOService")
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // Dependency injection for testability
    var dateProvider: () -> Date = { Date() }
    
    init(localDataService: LocalDataService) {
        self.localDataService = localDataService
        
        let cachePath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = cachePath.appendingPathComponent("SEOCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Metadata Generation
    
    /// Generate comprehensive SEO metadata for a question
    func generateMetadata(for question: Question) -> MetadataModel {
        let baseURL = URL(string: "https://driveai.app")!
        let questionPath = baseURL.appendingPathComponent("question").appendingPathComponent(question.id)
        
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
    
    /// Create shareable card with all metadata
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
    
    /// Batch create cards for trending questions
    func createShareableCards(for questions: [Question]) async throws -> [ShareableQuestionCard] {
        logger.info("Creating \(questions.count) shareable cards")
        return questions.map { createShareableCard(for: $0) }
    }
    
    // MARK: - Cache Management
    
    /// Cache generated card for offline access
    func cacheCard(_ card: ShareableQuestionCard) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(card)
        let cacheFile = cacheDirectory.appendingPathComponent("\(card.id).json")
        
        try data.write(to: cacheFile)
        logger.debug("Cached card: \(card.id)")
    }
    
    /// Retrieve cached card
    func retrieveCachedCard(id: String) throws -> ShareableQuestionCard? {
        let cacheFile = cacheDirectory.appendingPathComponent("\(id).json")
        
        guard fileManager.fileExists(atPath: cacheFile.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: cacheFile)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let card = try decoder.decode(ShareableQuestionCard.self, from: data)
        return card
    }
    
    // MARK: - Private Helpers
    
    private func generateDescription(for question: Question) -> String {
        let truncatedText = question.text.count > 100
            ? String(question.text.prefix(100)) + "..."
            : question.text
        
        return """
        \(truncatedText) — Lerne für deine Führerscheinprüfung mit DriveAI. \
        Kostenlose Fragen aus der offiziellen Katalog.
        """
    }
    
    private func generateKeywords(for question: Question) -> [String] {
        [
            "Führerschein",
            question.category.lowercased(),
            question.difficulty.rawValue,
            "Prüfung",
            "Fahrschule",
            "Deutschland"
        ]
    }
    
    private func generateDeepLink(for question: Question) -> URL {
        var components = URLComponents()
        components.scheme = "driveai"
        components.host = "question"
        components.path = "/\(question.id)"
        
        return components.url ?? URL(string: "driveai://question/\(question.id)")!
    }
    
    private func generateShareText(for question: Question) -> String {
        """
        🚗 Kannst du diese DriveAI-Frage richtig beantworten?
        
        \(question.text)
        
        Teste dein Wissen: driveai.app/q/\(question.id)
        #Führerschein #Prüfung
        """
    }
}

// MARK: - Error Handling

enum SEOServiceError: LocalizedError {
    case invalidURL
    case encodingFailed(String)
    case cacheFailed(String)
    case decodingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Die Deep-Link-URL ist ungültig."
        case .encodingFailed(let reason):
            return "Fehler beim Kodieren: \(reason)"
        case .cacheFailed(let reason):
            return "Cache-Fehler: \(reason)"
        case .decodingFailed(let reason):
            return "Dekodierungsfehler: \(reason)"
        }
    }
}