import SwiftUI

// DependencyContainer.swift
@MainActor
class DependencyContainer: ObservableObject {
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
    
    lazy var scoringService: BasicScoringService = {
        BasicScoringService(persistenceManager: self.persistenceManager)
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
    
    func makeQuizViewModel() -> AnyObject {
        // QuizViewModel creation - adjust based on actual QuizViewModel implementation
        return NSObject()
    }
    
    init() {
        self.persistenceManager = UserDefaultsPersistence()
        self.apiClient = APIClient(baseURL: URL(string: "https://api.driveai.app")!)
    }
}

// Alias to avoid ambiguity
typealias AppDependencyContainer = DependencyContainer

// EnvironmentKey for DependencyContainer
private struct ContainerKey: EnvironmentKey {
    @MainActor
    static var defaultValue: AppDependencyContainer {
        AppDependencyContainer()
    }
}

extension EnvironmentValues {
    var container: AppDependencyContainer {
        get { self[ContainerKey.self] }
        set { self[ContainerKey.self] = newValue }
    }
}

// Usage in view
struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    @MainActor
    init(container: AppDependencyContainer) {
        _viewModel = StateObject(wrappedValue: container.makeHomeViewModel())
    }
    
    var body: some View { EmptyView() }
}

// App entry
@MainActor
struct DriveAIApp: App {
    let container = AppDependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            HomeView(container: container)
                .environment(\.container, container)
        }
    }
}