import SwiftUI

// MARK: - DependencyContainer
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

    func makeQuizViewModel() -> AnyObject {
        let quizService = makeQuizService()
        let scoringService = ScoringService()
        _ = quizService
        _ = scoringService
        return NSObject()
    }

    private func makeQuizService() -> QuizService {
        QuizService(apiClient: apiClient)
    }
}