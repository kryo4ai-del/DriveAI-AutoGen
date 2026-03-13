import Foundation
import Combine

final class TopicCompetenceService: ObservableObject {

    @Published private(set) var competences: [TopicArea: TopicCompetence]
    @Published private(set) var spacingQueue: [TopicArea: SpacingItem]

    let config: TrainingConfig  // internal access for SkillMapViewModel projection
    private let store: PersistenceStore

    init(
        store: PersistenceStore = UserDefaultsStore(),
        config: TrainingConfig = .standard
    ) {
        self.store  = store
        self.config = config
        self.competences  = store.loadCompetences()
        self.spacingQueue = store.loadSpacingQueue()
        seedMissingTopics()
    }

    // MARK: - Public

    func record(result: SessionResult) {
        updateCompetence(for: result.topic, wasCorrect: result.wasCorrect)
        updateSpacing(for: result.topic, wasCorrect: result.wasCorrect)
        persist()
    }

    func dueTopics() -> [TopicArea] {
        spacingQueue.values
            .filter(\.isDue)
            .sorted { $0.nextReviewDate < $1.nextReviewDate }
            .map(\.topic)
    }

    func weakestTopics() -> [TopicArea] {
        competences.values
            .filter { $0.totalAnswers > 0 }
            .sorted { $0.weightedAccuracy < $1.weightedAccuracy }
            .map(\.topic)
    }

    func leastCoveredTopics() -> [TopicArea] {
        competences.values
            .sorted { $0.totalAnswers < $1.totalAnswers }
            .map(\.topic)
    }

    func nextSessionPreview() -> String? {
        guard let earliest = spacingQueue.values
            .sorted(by: { $0.nextReviewDate < $1.nextReviewDate })
            .first
        else { return nil }

        let name       = earliest.topic.displayName
        let competence = competences[earliest.topic]
        let errorCount = (competence?.totalAnswers ?? 0) - (competence?.correctAnswers ?? 0)

        if earliest.isDue {
            return "Heute: \(name) ist dran."
        }

        let days = Calendar.current.dateComponents(
            [.day], from: Date(), to: earliest.nextReviewDate
        ).day ?? 0

        let prefix = days <= 1 ? "Morgen" : "In \(days) Tagen"
        return errorCount > 0
            ? "\(prefix): \(name) — du hattest dort \(errorCount) Fehler."
            : "\(prefix): \(name) kommt zur Wiederholung."
    }

    // MARK: - Private

    private func updateCompetence(for topic: TopicArea, wasCorrect: Bool) {
        var entry = competences[topic] ?? TopicCompetence(topic: topic)
        entry.totalAnswers += 1
        if wasCorrect { entry.correctAnswers += 1 }
        entry.weightedAccuracy = updatedWeightedAccuracy(
            previous: entry.weightedAccuracy,
            wasCorrect: wasCorrect,
            totalAnswers: entry.totalAnswers
        )
        competences[topic] = entry
    }

    /// Exponential moving average with recency decay.
    /// First answer bypasses EMA to avoid cold-start underrepresentation.
    /// BUG-03 FIX: totalAnswers parameter is now used.
    private func updatedWeightedAccuracy(
        previous: Double,
        wasCorrect: Bool,
        totalAnswers: Int
    ) -> Double {
        let outcome: Double = wasCorrect ? 1.0 : 0.0
        guard totalAnswers > 1 else { return outcome }
        return previous * config.recencyDecay + outcome * (1.0 - config.recencyDecay)
    }

    private func updateSpacing(for topic: TopicArea, wasCorrect: Bool) {
        var item = spacingQueue[topic] ?? SpacingItem(
            topic: topic,
            consecutiveCorrect: 0,
            nextReviewDate: Date()
        )
        wasCorrect ? item.recordCorrect() : item.recordIncorrect()
        spacingQueue[topic] = item
    }

    private func persist() {
        store.save(competences: competences)
        store.save(spacingQueue: spacingQueue)
    }

    // ISSUE-02 FIX: persist immediately when topics are seeded.
    private func seedMissingTopics() {
        var seeded = false
        for topic in TopicArea.allCases where competences[topic] == nil {
            competences[topic] = TopicCompetence(topic: topic)
            seeded = true
        }
        if seeded { persist() }
    }
}
