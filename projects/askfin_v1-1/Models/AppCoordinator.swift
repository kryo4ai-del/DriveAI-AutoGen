// App/AppCoordinator.swift
@MainActor
final class AppCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    enum Destination: Hashable {
        case examSimulation
        case categoryBrowser
        case dashboard
        case results(ExamSession)
        case profile
    }
    
    func navigate(to destination: Destination) {
        navigationPath.append(destination)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}

// App/AppState.swift
@MainActor
final class AppState: ObservableObject {
    @Published var isOnboardingComplete = false
    @Published var examDate: Date?
    
    init() {
        self.isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboardingComplete")
        self.examDate = UserDefaults.standard.object(forKey: "examDate") as? Date
    }
}