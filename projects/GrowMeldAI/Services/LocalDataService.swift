import Foundation

@MainActor
final class LocalDataService {
    static let shared = LocalDataService()

    private var questionsCache: [Question] = []
    private var categoriesCache: [Category] = []

    private init() {}

    func fetchQuestions(category: Category? = nil) async throws -> [Question] {
        if questionsCache.isEmpty {
            try await loadCachedQuestions()
        }

        if let category = category {
            return questionsCache.filter { $0.category.id == category.id }
        }
        return questionsCache
    }

    func fetchCategories() async throws -> [Category] {
        if categoriesCache.isEmpty {
            if questionsCache.isEmpty {
                try await loadCachedQuestions()
            }
            try await loadCategories()
        }
        return categoriesCache
    }

    private func loadCachedQuestions() async throws {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            throw LocalDataError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        questionsCache = try decoder.decode([Question].self, from: data)
    }

    private func loadCategories() async throws {
        let uniqueCategories = Array(Set(questionsCache.map { $0.category }))
        categoriesCache = uniqueCategories.sorted { $0.name < $1.name }
    }
}

enum LocalDataError: LocalizedError {
    case fileNotFound
    case decodingFailed
    case databaseError(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Fragen-Datei nicht gefunden"
        case .decodingFailed:
            return "Fragen konnten nicht geladen werden"
        case .databaseError(let msg):
            return msg
        }
    }
}