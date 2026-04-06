// Tests/Mocks/MockQuizService.swift
class MockQuizService: QuizServiceProtocol {
    var createQuizSessionCallCount = 0
    var mockSession: QuizSession?
    
    func createQuizSession(for category: QuestionCategory?) -> QuizSession {
        createQuizSessionCallCount += 1
        return mockSession ?? QuizSession(
            questions: [.fixture()],
            currentQuestionIndex: 0
        )
    }
}

// Tests/Fixtures/QuestionFixture.swift
extension Question {
    static func fixture(
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
                Answer(id: "4", text: "Antwort D"),
            ],
            correctAnswerIndex: 0,
            explanation: "Test Erklärung",
            imageUrl: nil,
            difficulty: difficulty,
            estimatedTimeSeconds: 30
        )
    }
}