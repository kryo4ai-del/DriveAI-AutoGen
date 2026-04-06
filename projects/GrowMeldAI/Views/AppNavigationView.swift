import SwiftUI

struct AppNavigationView: View {
    @StateObject private var coordinator = NavigationCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            Group {
                if coordinator.isOnboarded {
                    HomeView()
                } else {
                    OnboardingView()
                }
            }
            .navigationDestination(for: AppNavigationPath.self) { path in
                switch path {
                case .home:
                    HomeView()
                case .categoryDetail(let categoryID):
                    CategoryDetailView(categoryID: categoryID)
                case .question(let questionID, let context):
                    QuestionView(questionID: questionID, context: context)
                }
            }
        }
        .environmentObject(coordinator)
    }
}

// MARK: - Navigation Path
enum AppNavigationPath: Hashable {
    case home
    case categoryDetail(categoryID: String)
    case question(questionID: String, context: String?)
}

// MARK: - Navigation Coordinator
class NavigationCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var isOnboarded: Bool

    init() {
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
    }

    func markOnboarded() {
        UserDefaults.standard.set(true, forKey: "isOnboarded")
        isOnboarded = true
    }

    func navigate(to path: AppNavigationPath) {
        navigationPath.append(path)
    }

    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func navigateToRoot() {
        navigationPath = NavigationPath()
    }
}

// MARK: - Stub Views
struct HomeView: View {
    var body: some View {
        Text("Home")
            .navigationTitle("Home")
    }
}

struct OnboardingView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator

    var body: some View {
        VStack(spacing: 24) {
            Text("Willkommen")
                .font(.largeTitle)
            Button("Weiter") {
                coordinator.markOnboarded()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Onboarding")
    }
}

struct CategoryDetailView: View {
    let categoryID: String

    var body: some View {
        Text("Kategorie: \(categoryID)")
            .navigationTitle("Kategorie")
    }
}

struct QuestionView: View {
    let questionID: String
    let context: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Frage: \(questionID)")
            if let context = context {
                Text("Kontext: \(context)")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Frage")
    }
}

// MARK: - Preview
#if DEBUG
struct AppNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        AppNavigationView()
    }
}
#endif