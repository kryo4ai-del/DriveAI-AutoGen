import Foundation

enum SessionType: String, Codable {
    case dailyChallenge = "dailyChallenge"
    case topicFocus     = "topicFocus"
    case reviewQueue    = "reviewQueue"
}

struct SessionResult: Identifiable, Codable {
    let id: UUID
    let questionID: UUID
    let topic: TopicArea
    let wasCorrect: Bool
    let selectedDirection: SwipeDirection
    let answeredAt: Date

    init(
        id: UUID = UUID(),
        questionID: UUID,
        topic: TopicArea,
        wasCorrect: Bool,
        selectedDirection: SwipeDirection,
        answeredAt: Date = Date()
    ) {
        self.id = id
        self.questionID = questionID
        self.topic = topic
        self.wasCorrect = wasCorrect
        self.selectedDirection = selectedDirection
        self.answeredAt = answeredAt
    }
}

struct TrainingSession: Identifiable, Codable {
    let id: UUID
    let sessionType: SessionType
    let results: [SessionResult]
    let startedAt: Date
    let completedAt: Date?

    init(
        id: UUID = UUID(),
        sessionType: SessionType,
        results: [SessionResult] = [],
        startedAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.sessionType = sessionType
        self.results = results
        self.startedAt = startedAt
        self.completedAt = completedAt
    }

    var correctCount: Int { results.filter(\.wasCorrect).count }
    var totalCount: Int   { results.count }

    // BUG-05 FIX: guard removed — Dictionary(grouping:) never produces empty arrays.
    var accuracyByTopic: [TopicArea: Double] {
        Dictionary(grouping: results, by: \.topic).mapValues { items in
            Double(items.filter(\.wasCorrect).count) / Double(items.count)
        }
    }
}
