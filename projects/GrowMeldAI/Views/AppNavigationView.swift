import SwiftUI

struct AppNavigationView: View {
    @StateObject private var coordinator = AppNavigationCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            Group {
                if coordinator.isOnboarded {
                    MainHomeView()
                } else {
                    MainOnboardingView()
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .home:
                    MainHomeView()
                case .category(let id):
                    CategoryDetailPlaceholderView(categoryID: id)
                case .results(let resultId):
                    QuestionPlaceholderView(questionID: resultId, context: nil)
                default:
                    EmptyView()
                }
            }
        }
        .environmentObject(coordinator)
    }
}

// AppRoute declared in Models/AppRoot.swift

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

    func navigateToCategory(_ id: String) {
        navigationPath.append(.category(id: id))
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

// MARK: - Local Views
private struct MainHomeView: View {
    var body: some View {
        Text("Home")
            .navigationTitle("Home")
    }
}

private struct MainOnboardingView: View {
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