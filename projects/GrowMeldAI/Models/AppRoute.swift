// ✅ Flat routing model
enum AppRoute: Hashable {
    case home
    case question(categoryId: Int, questionIndex: Int)
    case examFlow
    case examResult(result: ExamResult)
    case profile
}

@MainActor
class AppRouter: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    func navigate(to route: AppRoute) {
        navigationPath.append(route)
    }
}

// In SwiftUI
NavigationStack(path: $router.navigationPath) {
    HomeView()
        .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .question(let catId, let idx):
                QuestionView(categoryId: catId, questionIndex: idx)
            case .examFlow:
                ExamView()
            // ...
            }
        }
}