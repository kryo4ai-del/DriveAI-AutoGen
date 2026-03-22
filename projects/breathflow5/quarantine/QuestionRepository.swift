// ✅ Protocol
protocol QuestionRepository {
    func getQuestions(category: String) async throws -> [Question]
}

// ✅ Live implementation

// ✅ Mock for testing
final class QuestionRepositoryMock: QuestionRepository {
    var mockQuestions: [Question] = []
    
    func getQuestions(category: String) async throws -> [Question] {
        return mockQuestions
    }
}

// ✅ ViewModel accepts dependency
@MainActor

// ✅ Easy to test
let mockRepo = QuestionRepositoryMock()
mockRepo.mockQuestions = [sampleQuestion1, sampleQuestion2]
let viewModel = QuizViewModel(repository: mockRepo)