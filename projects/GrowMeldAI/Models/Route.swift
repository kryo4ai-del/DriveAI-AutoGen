// Navigation/Route.swift
enum Route: Hashable {
    case onboarding
    case home
    case quiz(categoryId: UUID)
    case exam
    case examResult(score: Int, passed: Bool)
    case profile
}

// ViewModels/AppViewModel.swift
class AppViewModel: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var hasCompletedOnboarding: Bool = false
    
    func navigate(to route: Route) {
        navigationPath.append(route)
    }
    
    func reset() {
        navigationPath = NavigationPath()
    }
}

// Views/AppView.swift (entry point)
NavigationStack(path: $viewModel.navigationPath) {
    if !viewModel.hasCompletedOnboarding {
        OnboardingView()
    } else {
        DashboardView()
    }
    .navigationDestination(for: Route.self) { route in
        routeView(route)
    }
}