import SwiftUI

@MainActor
final class NavigationCoordinator: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    @Published var isOnboardingComplete: Bool = false
    
    private let persistenceManager: UserDefaultsManager
    
    init(persistenceManager: UserDefaultsManager) {
        self.persistenceManager = persistenceManager
        self.isOnboardingComplete = persistenceManager.isOnboardingComplete
    }
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func completeOnboarding(examDate: Date) throws {
        persistenceManager.setExamDate(examDate)
        persistenceManager.setOnboardingComplete(true)
        self.isOnboardingComplete = true
    }
}