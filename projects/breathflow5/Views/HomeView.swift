import SwiftUI

// DependencyContainer.swift
@MainActor
class DependencyContainer: ObservableObject {
    // Singletons
    let persistenceManager: PersistenceManager
    let apiClient: APIClient
    
    // Services
    lazy var quizService: QuizService = {
        QuizService()
    }()
    
    lazy var readinessCalculator: ReadinessCalculator = {
        ReadinessCalculator()
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

// EnvironmentKey for DependencyContainer
private struct ContainerKey: EnvironmentKey {
    @MainActor
    static var defaultValue: DependencyContainer {
        DependencyContainer()
    }
}

extension EnvironmentValues {
    var container: DependencyContainer {
        get { self[ContainerKey.self] }
        set { self[ContainerKey.self] = newValue }
    }
}

// Usage in view
struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    @MainActor
    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: container.makeHomeViewModel())
    }
    
    var body: some View { EmptyView() }
}

// App entry
@MainActor
struct DriveAIApp: App {
    let container = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            HomeView(container: container)
                .environment(\.container, container)
        }
    }
}

class HomeViewModel: ObservableObject {
    let quizService: QuizService
    let readinessCalculator: ReadinessCalculator
    
    init(quizService: QuizService, readinessCalculator: ReadinessCalculator) {
        self.quizService = quizService
        self.readinessCalculator = readinessCalculator
    }
}