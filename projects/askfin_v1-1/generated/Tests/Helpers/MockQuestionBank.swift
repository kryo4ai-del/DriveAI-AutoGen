import Foundation
@testable import DriveAI

final class MockQuestionBank: QuestionBankProtocol {

    var questionsByTopic: [TopicArea: [SessionQuestion]] = [:]
    private(set) var randomCallCount = 0
    private(set) var lastRequestedTopic: TopicArea?

    func randomQuestion(for topic: TopicArea, revealMode: RevealMode) -> SessionQuestion? {
        randomCallCount += 1
        lastRequestedTopic = topic
        guard let prototype = questionsByTopic[topic]?.first else { return nil }
        return SessionQuestion(
            id: prototype.id,
            text: prototype.text,
            options: prototype.options,
            correctIndex: prototype.correctIndex,
            topic: prototype.topic,
            questionType: prototype.questionType,
            explanation: prototype.explanation,
            revealMode: revealMode
        )
    }

    func questions(for topic: TopicArea) -> [SessionQuestion] {
        questionsByTopic[topic] ?? []
    }

    func seedAllTopics() {
        for topic in TopicArea.allCases {
            questionsByTopic[topic] = [TestFixtures.makeQuestion(topic: topic)]
        }
    }
}