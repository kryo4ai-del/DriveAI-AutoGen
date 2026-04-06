// Container for all services (single source of truth)
class DIContainer {
    static let shared = DIContainer()
    
    lazy var questionRepository: QuestionRepositoryProtocol = {
        QuestionRepository(dataService: localDataService)
    }()
    
    lazy var quizService: QuizService = {
        QuizService(questionRepository: questionRepository)
    }()
    
    lazy var localDataService: LocalDataService = {
        LocalDataService()
    }()
}

// Usage in views:
@main

// In ViewModels:
@StateObject var quizVM = QuizSessionViewModel(
    quizService: DIContainer.shared.quizService
)