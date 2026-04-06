import SwiftUI

enum AppRoute: Hashable {
    case onboarding
    case home
    case quiz(categoryId: String?)
    case category(id: String)
    case exam
    case results(String)
    case profile

    func hash(into hasher: inout Hasher) {
        switch self {
        case .onboarding:
            hasher.combine(0)
        case .home:
            hasher.combine(1)
        case .quiz(let categoryId):
            hasher.combine(2)
            hasher.combine(categoryId)
        case .category(let id):
            hasher.combine(3)
            hasher.combine(id)
        case .exam:
            hasher.combine(4)
        case .results(let resultId):
            hasher.combine(5)
            hasher.combine(resultId)
        case .profile:
            hasher.combine(6)
        }
    }

    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
        case (.onboarding, .onboarding): return true
        case (.home, .home): return true
        case (.quiz(let a), .quiz(let b)): return a == b
        case (.category(let a), .category(let b)): return a == b
        case (.exam, .exam): return true
        case (.results(let a), .results(let b)): return a == b
        case (.profile, .profile): return true
        default: return false
        }
    }
}

@MainActor
struct AppRoot: View {
    @StateObject private var coordinator = NavigationCoordinator()

    var body: some View {
        if coordinator.isOnboardingComplete {
            NavigationStack(path: $coordinator.path) {
                DashboardView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .quiz(let categoryId):
                            QuizSessionView(categoryId: categoryId)
                        case .exam:
                            ExamSimulationView()
                        case .results(let resultId):
                            ResultsView(resultId: resultId)
                        case .profile:
                            ProfileView()
                        default:
                            EmptyView()
                        }
                    }
            }
            .environmentObject(coordinator)
        } else {
            NavigationStack(path: $coordinator.path) {
                WelcomeView()
                    .navigationDestination(for: AppRoute.self) { route in
                        if case .onboarding = route {
                            ExamDatePickerView()
                        }
                    }
            }
            .environmentObject(coordinator)
        }
    }
}