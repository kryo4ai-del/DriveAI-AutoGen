// Routes enum — single source of truth for navigation

import SwiftUI

// MARK: - App Routes

enum AppRoute: Hashable {
    case dashboard
    case category(id: String)
    case question(id: String)
    case exam
    case result(score: Double)
    case profile
}

// MARK: - Navigation Stack Controller

final class NavigationStackController: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

// MARK: - Root navigation coordinator

struct AppNavigationStack: View {
    @StateObject private var navStack = NavigationStackController()

    var body: some View {
        NavigationStack(path: $navStack.path) {
            DashboardView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .category(let id):
                        CategoryDetailView(categoryId: id)
                    case .question(let id):
                        QuestionView(questionId: id)
                    case .exam:
                        ExamView()
                    case .result(let score):
                        ResultView(score: score)
                    case .profile:
                        ProfileView()
                    default:
                        DashboardView()
                    }
                }
        }
        .environmentObject(navStack)
    }
}

// MARK: - ViewModel can trigger navigation