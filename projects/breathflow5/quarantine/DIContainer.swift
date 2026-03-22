final class DIContainer {
    enum Environment {
        case test
        case production
    }
    
    private let environment: Environment
    
    init(environment: Environment = .production) {
        self.environment = environment
    }
    
    func makeQuestionRepository() -> QuestionRepository {
        switch environment {
        case .test:
            return QuestionRepositoryMock()
        case .production:
            return QuestionRepositoryLive(
                urlSession: URLSession.shared
            )
        }
    }
    
    func makeQuizViewModel() -> QuizViewModel {
        QuizViewModel(
            repository: makeQuestionRepository(),
            readinessCalculator: ReadinessCalculator()
        )
    }
}

// App setup
@main