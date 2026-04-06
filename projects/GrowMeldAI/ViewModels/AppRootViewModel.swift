@MainActor
class AppRootViewModel: ObservableObject {
    @Published var navigationPath: NavigationPath = NavigationPath()
    
    enum Screen: Hashable {
        case dashboard
        case keywordDetail(KeywordMetric)
        case reviewList
        case competitorDetail(CompetitorSnapshot)
        case recommendations
    }
    
    func navigate(to screen: Screen) {
        navigationPath.append(screen)
    }
}

// In ASOApp
NavigationStack(path: $rootVM.navigationPath) {
    DashboardView(viewModel: dashboardVM)
        .navigationDestination(for: AppRootViewModel.Screen.self) { screen in
            switch screen {
            case .keywordDetail(let metric):
                KeywordDetailView(metric: metric)
            // ...
            }
        }
}