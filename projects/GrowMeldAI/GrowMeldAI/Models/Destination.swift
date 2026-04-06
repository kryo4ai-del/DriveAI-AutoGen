enum Destination: Hashable {
    case quiz(category: Category)
    case examSimulation
    case categoryDetail(category: Category)
    case profile
    case settings
}

@Observable final class NavigationViewModel {
    @ObservationIgnored var path = NavigationPath()
    
    func navigate(to destination: Destination) {
        path.append(destination)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}

// In DashboardView:
NavigationStack(path: $navigationViewModel.path) {
    DashboardContent()
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case .quiz(let category):
                QuizView(category: category, viewModel: quizVM)
            case .examSimulation:
                ExamSimulationView(viewModel: examVM)
            case .categoryDetail(let category):
                CategoryDetailView(category: category)
            case .profile:
                ProfileView()
            case .settings:
                SettingsView()
            }
        }
}