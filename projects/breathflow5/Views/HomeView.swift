import SwiftUI

// DependencyContainer.swift
@MainActor
class DependencyContainer {
    // Singletons
    let persistenceManager: PersistenceManager
    let apiClient: APIClient
    
    // Services
    lazy var quizService: QuizService = {
        QuizService(
            persistenceManager: persistenceManager,
            apiClient: apiClient
        )
    }()
    
    lazy var scoringService: ScoringService = {
        ScoringService(persistenceManager: persistenceManager)
    }()
    
    lazy var readinessCalculator: ReadinessCalculator = {
        ReadinessCalculator(persistenceManager: persistenceManager)
    }()
    
    // ViewModels
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            quizService: quizService,
            readinessCalculator: readinessCalculator
        )
    }
    
    func makeQuizViewModel() -> QuizViewModel {
        QuizViewModel(
            quizService: quizService,
            scoringService: scoringService
        )
    }
    
    init() {
        self.persistenceManager = UserDefaultsPersistence()
        self.apiClient = APIClient(baseURL: URL(string: "https://api.driveai.app")!)
    }
}

// App entry
@main

// Usage in view
struct HomeView: View {
    @Environment(\.container) var container
    @StateObject var viewModel: HomeViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: container.makeHomeViewModel())
    }
    
    var body: some View { /* ... */ }
}