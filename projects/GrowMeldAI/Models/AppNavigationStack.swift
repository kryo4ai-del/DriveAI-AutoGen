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
    @Published var path: [AppRoute] = []

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func popToRoot() {
        path = []
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

// MARK: - Placeholder Views

private struct CategoryDetailView: View {
    let categoryId: String
    var body: some View {
        Text("Category: \(categoryId)")
    }
}

private struct QuestionView: View {
    let questionId: String
    var body: some View {
        Text("Question: \(questionId)")
    }
}

private struct ExamView: View {
    var body: some View {
        Text("Exam")
    }
}

private struct ResultView: View {
    let score: Double
    var body: some View {
        Text("Result: \(score)")
    }
}

private struct ProfileView: View {
    var body: some View {
        Text("Profile")
    }
}

private struct DashboardView: View {
    var body: some View {
        Text("Dashboard")
    }
}

// MARK: - Root Navigation Coordinator

struct AppNavigationStack: View {
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