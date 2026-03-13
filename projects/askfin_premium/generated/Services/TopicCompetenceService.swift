import Foundation

/// Manages topic-level competence tracking with spaced repetition
@MainActor
class TopicCompetenceService: ObservableObject {
    @Published var competenceMap: [String: TopicCompetence] = [:]
    @Published var spacingQueue: [SpacingItem] = []
    
    private let defaults = UserDefaults.standard
    private let competenceKey = "driveai_competence_map"
    private let spacingKey = "driveai_spacing_queue"
    
    init() {
        loadPersistedState()
    }
    
    // MARK: - Core API
    
    /// Record an answer and update competence + spacing
    func recordAnswer(topicId: String, questionId: String, isCorrect: Bool) {
        // Update competence
        if var competence = competenceMap[topicId] {
            competence.totalAnswers += 1
            if isCorrect {
                competence.correctAnswers += 1
            }
            competence.lastReviewedDate = Date()
            competence.weightedAccuracy = Double(competence.correctAnswers) / Double(competence.totalAnswers)
            competenceMap[topicId] = competence
        } else {
            var newCompetence = TopicCompetence(id: topicId, topic: TopicArea(rawValue: topicId) ?? .general)
            newCompetence.totalAnswers = 1
            newCompetence.correctAnswers = isCorrect ? 1 : 0
            newCompetence.lastReviewedDate = Date()
            newCompetence.weightedAccuracy = isCorrect ? 1.0 : 0.0
            competenceMap[topicId] = newCompetence
        }
        
        // Update spacing queue
        if var spacingItem = spacingQueue.first(where: { $0.id == questionId }) {
            if isCorrect {
                spacingItem.consecutiveCorrect += 1
                let interval = SpacingItem.nextInterval(after: spacingItem.consecutiveCorrect)
                spacingItem.nextReviewDate = Calendar.current.date(byAdding: .day, value: interval, to: Date())!
            } else {
                spacingItem.consecutiveCorrect = 0
                spacingItem.nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            }
            spacingItem.reviewCount += 1
            
            if let index = spacingQueue.firstIndex(where: { $0.id == questionId }) {
                spacingQueue[index] = spacingItem
            }
        }
        
        persistState()
    }
    
    /// Get due-for-review items (spaced repetition)
    func spacingDueItems() -> [SpacingItem] {
        spacingQueue.filter { $0.nextReviewDate <= Date() }
            .sorted { $0.nextReviewDate < $1.nextReviewDate }
    }
    
    /// Get weakest topics for focused review
    func weakestTopics(limit: Int = 5) -> [TopicCompetence] {
        competenceMap.values
            .filter { $0.competenceLevel < .solid }
            .sorted { $0.weightedAccuracy < $1.weightedAccuracy }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Get overall readiness score (0-100%)
    var overallReadiness: Int {
        guard !competenceMap.isEmpty else { return 0 }
        let avgAccuracy = competenceMap.values.reduce(0) { $0 + $1.weightedAccuracy } / Double(competenceMap.count)
        return Int(avgAccuracy * 100)
    }
    
    /// Initialize spacing queue from all questions
    func initializeSpacingQueue(with questions: [SessionQuestion]) {
        var queue: [SpacingItem] = []
        for question in questions {
            let item = SpacingItem(
                id: question.id.uuidString,
                topic: question.topic,
                consecutiveCorrect: 0,
                nextReviewDate: Date(),
                reviewCount: 0
            )
            queue.append(item)
        }
        spacingQueue = queue
        persistState()
    }
    
    // MARK: - Persistence
    
    private func loadPersistedState() {
        if let data = defaults.data(forKey: competenceKey),
           let decoded = try? JSONDecoder().decode([String: TopicCompetence].self, from: data) {
            competenceMap = decoded
        }
        
        if let data = defaults.data(forKey: spacingKey),
           let decoded = try? JSONDecoder().decode([SpacingItem].self, from: data) {
            spacingQueue = decoded
        }
    }
    
    private func persistState() {
        if let encoded = try? JSONEncoder().encode(competenceMap) {
            defaults.set(encoded, forKey: competenceKey)
        }
        if let encoded = try? JSONEncoder().encode(spacingQueue) {
            defaults.set(encoded, forKey: spacingKey)
        }
    }
}