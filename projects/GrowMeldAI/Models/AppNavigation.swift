import SwiftUI

// MARK: - App Navigation

struct AppNavigation: View {
    @StateObject private var navStack = NavigationStackController()

    var body: some View {
        NavigationStack(path: $navStack.path) {
            DashboardView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .dashboard:
                        DashboardView()
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
                    }
                }
        }
        .environmentObject(navStack)
    }
}