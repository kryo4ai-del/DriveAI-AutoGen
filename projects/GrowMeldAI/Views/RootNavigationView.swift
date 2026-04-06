import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.colorTheme) var theme
    
    var body: some View {
        if coordinator.isOnboardingComplete {
            mainNavigation
        } else {
            onboardingNavigation
        }
    }
    
    @ViewBuilder
    private var onboardingNavigation: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            OnboardingView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
    
    @ViewBuilder
    private var mainNavigation: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            HomeScreenView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .onboarding:
            OnboardingView()
            
        case .home:
            HomeScreenView()
            
        case .categories:
            CategoryOverviewView()
            
        case .question(let categoryId):
            QuestionScreenView(categoryId: categoryId)
            
        case .examMode:
            ExamSimulationView()
            
        case .examResult(let result):
            ResultScreenView(result: result)
            
        case .profile:
            ProfileScreenView()
        }
    }
}