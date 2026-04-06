import SwiftUI

struct AppNavigationView: View {
    @StateObject private var coordinator = AppNavigationCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            Group {
                if coordinator.isOnboarded {
                    HomeView()
                } else {
                    OnboardingView()
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .home:
                    HomeView()
                case .categoryDetail(let categoryID):
                    CategoryDetailPlaceholderView(categoryID: categoryID)
                case .question(let questionID, let context):
                    QuestionPlaceholderView(questionID: questionID, context: context)
                }
            }
        }
        .environmentObject(coordinator)
    }
}

// MARK: - Navigation Path
enum AppRoute: Hashable {
    case home
    case categoryDetail(categoryID: String)
    case question(questionID: String, context: String?)
}

// MARK: - Navigation Coordinator
class AppNavigationCoordinator: ObservableObject {
    @Published var navigationPath = [AppRoute]()
    @Published var isOnboarded: Bool

    init() {
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
    }

    func markOnboarded() {
        UserDefaults.standard.set(true, forKey: "isOnboarded")
        isOnboarded = true
    }

    func navigate(to route: AppRoute) {
        navigationPath.append(route)
    }

    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func navigateToRoot() {
        navigationPath = []
    }
}

// MARK: - Placeholder Views
private struct CategoryDetailPlaceholderView: View {
    let categoryID: String
    var body: some View {
        Text("Category: \(categoryID)")
            .navigationTitle("Category")
    }
}

private struct QuestionPlaceholderView: View {
    let questionID: String
    let context: String?
    var body: some View {
        Text("Question: \(questionID)")
            .navigationTitle("Question")
    }
}

// MARK: - Stub Views
private struct HomeView: View {
    var body: some View {
        Text("Home")
            .navigationTitle("Home")
    }
}

private struct OnboardingView: View {
    @EnvironmentObject var coordinator: AppNavigationCoordinator
    var body: some View {
        VStack {
            Text("Onboarding")
            Button("Continue") {
                coordinator.markOnboarded()
            }
        }
        .navigationTitle("Welcome")
    }
}

// MARK: - Preview
#if DEBUG
struct AppNavigationView_Preview: PreviewProvider {
    static var previews: some View {
        AppNavigationView()
    }
}
#endif