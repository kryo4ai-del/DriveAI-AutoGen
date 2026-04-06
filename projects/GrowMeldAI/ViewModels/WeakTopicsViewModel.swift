import Foundation

// MARK: - Protocol Definitions

protocol LocalDataServiceProtocol {
    func fetchWeakTopics() -> [WeakTopic]
    func saveWeakTopic(_ topic: WeakTopic)
    func removeWeakTopic(id: String)
}

protocol ProgressServiceProtocol {
    func progressScore(for topicId: String) -> Double
    func markTopicImproved(id: String)
}

// MARK: - Model

struct WeakTopic: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var category: String
    var score: Double
    var lastReviewedAt: Date?

    init(id: String = UUID().uuidString,
         title: String,
         category: String,
         score: Double,
         lastReviewedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.category = category
        self.score = score
        self.lastReviewedAt = lastReviewedAt
    }
}

// MARK: - Concrete Services

final class LocalDataService: LocalDataServiceProtocol {
    static let shared = LocalDataService()

    private let storageKey = "weak_topics_storage"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    func fetchWeakTopics() -> [WeakTopic] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let topics = try? decoder.decode([WeakTopic].self, from: data) else {
            return []
        }
        return topics
    }

    func saveWeakTopic(_ topic: WeakTopic) {
        var topics = fetchWeakTopics()
        if let index = topics.firstIndex(where: { $0.id == topic.id }) {
            topics[index] = topic
        } else {
            topics.append(topic)
        }
        if let data = try? encoder.encode(topics) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func removeWeakTopic(id: String) {
        var topics = fetchWeakTopics()
        topics.removeAll { $0.id == id }
        if let data = try? encoder.encode(topics) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

final class ProgressService: ProgressServiceProtocol {
    static let shared = ProgressService()

    private let scoresKey = "progress_scores"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    private func loadScores() -> [String: Double] {
        guard let data = UserDefaults.standard.data(forKey: scoresKey),
              let scores = try? decoder.decode([String: Double].self, from: data) else {
            return [:]
        }
        return scores
    }

    private func saveScores(_ scores: [String: Double]) {
        if let data = try? encoder.encode(scores) {
            UserDefaults.standard.set(data, forKey: scoresKey)
        }
    }

    func progressScore(for topicId: String) -> Double {
        return loadScores()[topicId] ?? 0.0
    }

    func markTopicImproved(id: String) {
        var scores = loadScores()
        let current = scores[id] ?? 0.0
        scores[id] = min(current + 0.1, 1.0)
        saveScores(scores)
    }
}

// MARK: - Mock Services (for testing)

final class MockLocalDataService: LocalDataServiceProtocol {
    var storedTopics: [WeakTopic] = []

    func fetchWeakTopics() -> [WeakTopic] {
        return storedTopics
    }

    func saveWeakTopic(_ topic: WeakTopic) {
        if let index = storedTopics.firstIndex(where: { $0.id == topic.id }) {
            storedTopics[index] = topic
        } else {
            storedTopics.append(topic)
        }
    }

    func removeWeakTopic(id: String) {
        storedTopics.removeAll { $0.id == id }
    }
}

final class MockProgressService: ProgressServiceProtocol {
    var scores: [String: Double] = [:]
    var improvedTopicIds: [String] = []

    func progressScore(for topicId: String) -> Double {
        return scores[topicId] ?? 0.0
    }

    func markTopicImproved(id: String) {
        improvedTopicIds.append(id)
        scores[id] = min((scores[id] ?? 0.0) + 0.1, 1.0)
    }
}

// MARK: - ViewModel

@MainActor
final class WeakTopicsViewModel: ObservableObject {
    @Published var weakTopics: [WeakTopic] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let dataService: LocalDataServiceProtocol
    private let progressService: ProgressServiceProtocol

    init(
        dataService: LocalDataServiceProtocol,
        progressService: ProgressServiceProtocol
    ) {
        self.dataService = dataService
        self.progressService = progressService
    }

    // MARK: - Public Methods

    func loadWeakTopics() {
        isLoading = true
        errorMessage = nil

        let topics = dataService.fetchWeakTopics()
        self.weakTopics = topics.sorted { $0.score < $1.score }

        isLoading = false
    }

    func addWeakTopic(_ topic: WeakTopic) {
        dataService.saveWeakTopic(topic)
        loadWeakTopics()
    }

    func removeWeakTopic(id: String) {
        dataService.removeWeakTopic(id: id)
        weakTopics.removeAll { $0.id == id }
    }

    func markTopicImproved(id: String) {
        progressService.markTopicImproved(id: id)
        loadWeakTopics()
    }

    func progressScore(for topicId: String) -> Double {
        return progressService.progressScore(for: topicId)
    }

    var hasWeakTopics: Bool {
        !weakTopics.isEmpty
    }

    var topWeakTopics: [WeakTopic] {
        Array(weakTopics.prefix(5))
    }
}

// MARK: - Factory

extension WeakTopicsViewModel {
    /// Creates a production instance using shared singletons
    static func makeProduction() -> WeakTopicsViewModel {
        WeakTopicsViewModel(
            dataService: LocalDataService.shared,
            progressService: ProgressService.shared
        )
    }

    /// Creates a test instance using mock services
    static func makeForTesting(
        topics: [WeakTopic] = [],
        scores: [String: Double] = [:]
    ) -> WeakTopicsViewModel {
        let mockDataService = MockLocalDataService()
        mockDataService.storedTopics = topics

        let mockProgressService = MockProgressService()
        mockProgressService.scores = scores

        return WeakTopicsViewModel(
            dataService: mockDataService,
            progressService: mockProgressService
        )
    }
}