import Foundation

struct SimulationConfig: Codable, Equatable {

    let questionCount: Int
    let timeLimit: TimeInterval
    let mode: SimulationMode
    let topicWeights: [String: Double]

    var hasValidWeights: Bool {
        abs(topicWeights.values.reduce(0.0, +) - 1.0) < 0.001
    }

    static let officialExam = SimulationConfig(
        questionCount: 30,
        timeLimit: 45 * 60,
        mode: .realistic,
        topicWeights: TopicArea.officialExamWeights
    )

    static let practice = SimulationConfig(
        questionCount: 30,
        timeLimit: 60 * 60,
        mode: .practice,
        topicWeights: TopicArea.officialExamWeights
    )
}