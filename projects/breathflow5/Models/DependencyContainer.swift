final class DependencyContainer: ObservableObject {
    let persistenceManager: PersistenceManager
    let apiClient: APIClient

    init() {
        self.persistenceManager = UserDefaultsPersistence()
        self.apiClient = APIClient(baseURL: URL(string: "https://api.driveai.example.com")!)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            persistenceManager: persistenceManager,
            quizService: makeQuizService()
        )
    }

    func makeQuizViewModel() -> QuizViewModel {
        QuizViewModel(
            quizService: makeQuizService(),
            scoringService: ScoringService()
        )
    }

    private func makeQuizService() -> QuizService {
        QuizService(apiClient: apiClient)
    }
}