import SwiftUI

enum AppRoute: Hashable {
    case onboarding
    case home
    case quiz(categoryId: String?)
    case category(id: String)
    case exam
    case results(ExamResult)
    case profile
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
                        case .results(let result):
                            ResultsView(result: result)
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