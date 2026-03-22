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
            persistenceManager: self.persistenceManager,
            apiClient: self.apiClient
        )
    }()
    
    lazy var scoringService: ScoringService = {
        ScoringService(persistenceManager: self.persistenceManager)
    }()
    
    lazy var readinessCalculator: ReadinessCalculator = {
        ReadinessCalculator(persistenceManager: self.persistenceManager)
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

// EnvironmentKey for DependencyContainer
private struct ContainerKey: EnvironmentKey {
    @MainActor static let defaultValue = AppDependencyContainer()
}

extension EnvironmentValues {
    var container: AppDependencyContainer {
        get { self[ContainerKey.self] }
        set { self[ContainerKey.self] = newValue }
    }
}

// Alias to avoid ambiguity
typealias AppDependencyContainer = DependencyContainer

// Usage in view
struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    init(container: AppDependencyContainer) {
        _viewModel = StateObject(wrappedValue: container.makeHomeViewModel())
    }
    
    var body: some View { EmptyView() }
}

// App entry
struct DriveAIApp: App {
    let container = AppDependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            HomeView(container: container)
                .environment(\.container, container)
        }
    }
}