import Foundation

class MockQuizService: QuizServiceProtocol {
    var createQuizSessionCallCount = 0
    var mockSession: QuizSession?

    func createQuizSession(for category: QuestionCategory?) -> QuizSession {
        createQuizSessionCallCount += 1
        return mockSession ?? QuizSession(
            questions: [Question.makeMock()],
            currentQuestionIndex: 0
        )
    }
}

extension Question {
    static func makeMock(
        id: String = UUID().uuidString,
        category: QuestionCategory = .trafficSigns,
        difficulty: DifficultyLevel = .medium
    ) -> Question {
        Question(
            id: id,
            text: "Test Frage",
            category: category,
            answers: [
                Answer(id: "1", text: "Antwort A"),
                Answer(id: "2", text: "Antwort B"),
                Answer(id: "3", text: "Antwort C"),
                Answer(id: "4", text: "Antwort D")
            ],
            correctAnswerIndex: 0,
            explanation: "Test Erklärung",
            imageUrl: nil,
            difficulty: difficulty,
            estimatedTimeSeconds: 30
        )
    }
}