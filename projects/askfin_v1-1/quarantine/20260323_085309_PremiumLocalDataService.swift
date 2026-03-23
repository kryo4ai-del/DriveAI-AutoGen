import Foundation

enum PremiumDataServiceError: LocalizedError {
    case categoryNotFound(String)
    case questionNotFound(String)
    case corruptedData(String)
    case persistenceFailure(String)
    case invalidJSON(String)
    
    var errorDescription: String? {
        switch self {
        case .categoryNotFound(let id):
            return "Kategorie '\(id)' nicht gefunden."
        case .questionNotFound(let id):
            return "Frage '\(id)' nicht gefunden."
        case .corruptedData(let msg):
            return "Datenfehler: \(msg)"
        case .persistenceFailure(let msg):
            return "Fehler beim Speichern: \(msg)"
        case .invalidJSON(let msg):
            return "Ungültiges Datenformat: \(msg)"
        }
    }
}

protocol PremiumLocalDataServiceProtocol {
    func fetchQuestions(for categoryId: String) async throws -> [PremiumQuestion]
    func fetchCategories() async throws -> [PremiumCategory]
    func saveSession(_ session: PracticeSession) async throws
    func loadSession(_ id: UUID) async throws -> PracticeSession?
    func deleteSession(_ id: UUID) async throws
    func fetchQuestionsByDifficulty(_ difficulty: Int, categoryId: String) async throws -> [PremiumQuestion]
}

actor PremiumDefaultLocalDataService: PremiumLocalDataServiceProtocol {
    private var questionsCache: [String: [PremiumQuestion]] = [:]
    private var categoriesCache: [PremiumCategory]?
    private let fileManager = FileManager.default
    private let sessionDirectory: URL
    
    init() throws {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        sessionDirectory = paths[0].appendingPathComponent("sessions", isDirectory: true)
        
        if !fileManager.fileExists(atPath: sessionDirectory.path) {
            try fileManager.createDirectory(at: sessionDirectory, withIntermediateDirectories: true)
        }
    }
    
    nonisolated static let shared: PremiumDefaultLocalDataService = {
        do {
            return try PremiumDefaultLocalDataService()
        } catch {
            fatalError("Failed to initialize LocalDataService: \(error)")
        }
    }()
    
    // MARK: - Questions
    
    func fetchQuestions(for categoryId: String) async throws -> [PremiumQuestion] {
        if let cached = questionsCache[categoryId] {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            throw PremiumDataServiceError.categoryNotFound(categoryId)
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let questions: [PremiumQuestion] = try decoder.decode([PremiumQuestion].self, from: data)
            let filtered = questions.filter { $0.categoryId == categoryId }
            questionsCache[categoryId] = filtered
            return filtered
        } catch {
            throw PremiumDataServiceError.invalidJSON(error.localizedDescription)
        }
    }
    
    func fetchQuestionsByDifficulty(_ difficulty: Int, categoryId: String) async throws -> [PremiumQuestion] {
        let all = try await fetchQuestions(for: categoryId)
        return all.filter { $0.difficulty == difficulty }
    }
    
    // MARK: - Categories
    
    func fetchCategories() async throws -> [PremiumCategory] {
        if let cached = categoriesCache {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "categories", withExtension: "json") else {
            throw PremiumDataServiceError.categoryNotFound("categories")
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        
        do {
            let categories: [PremiumCategory] = try decoder.decode([PremiumCategory].self, from: data)
            categoriesCache = categories
            return categories
        } catch {
            throw PremiumDataServiceError.invalidJSON(error.localizedDescription)
        }
    }
    
    // MARK: - Session Persistence
    
    func saveSession(_ session: PracticeSession) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(session)
        let fileURL = sessionDirectory.appendingPathComponent("\(session.id.uuidString).json")
        
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw PremiumDataServiceError.persistenceFailure("Fehler beim Speichern der Sitzung: \(error.localizedDescription)")
        }
    }
    
    func loadSession(_ id: UUID) async throws -> PracticeSession? {
        let fileURL = sessionDirectory.appendingPathComponent("\(id.uuidString).json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(PracticeSession.self, from: data)
        } catch {
            throw PremiumDataServiceError.corruptedData("Fehler beim Laden der Sitzung: \(error.localizedDescription)")
        }
    }
    
    func deleteSession(_ id: UUID) async throws {
        let fileURL = sessionDirectory.appendingPathComponent("\(id.uuidString).json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return
        }
        
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            throw PremiumDataServiceError.persistenceFailure("Fehler beim Löschen: \(error.localizedDescription)")
        }
    }
}
