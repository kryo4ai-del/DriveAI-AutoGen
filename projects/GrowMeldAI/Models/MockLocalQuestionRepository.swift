// File: Tests/Mocks/MockQuestionRepository.swift

class MockLocalQuestionRepository: LocalQuestionRepository {
    var questions: [LocalQuestion] = []
    var lastSyncDate = Date()
    
    override func getQuestions(category: String?) async throws -> [LocalQuestion] {
        return questions
    }
    
    override func upsertQuestions(_ questions: [RemoteQuestion]) async throws -> Int {
        self.questions += questions.map { LocalQuestion(from: $0) }
        return questions.count
    }
}

class MockRemoteRepository: RemoteQuestionRepository {
    var shouldFail = false
    var questionsToReturn: [RemoteQuestion] = []
    
    override func fetchQuestionsSince(_ date: Date) async throws -> [RemoteQuestion] {
        if shouldFail {
            throw ResilienceError.network(.connectionLost)
        }
        return questionsToReturn
    }
}