import SwiftUI

struct AppNavigation: View {
    @StateObject private var navStack = NavigationStackController()

    var body: some View {
        NavigationStack(path: $navStack.path) {
            DashboardPlaceholderView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .dashboard:
                        DashboardPlaceholderView()
                    case .category(let id):
                        CategoryPlaceholderView(categoryId: id)
                    case .question(let id):
                        QuestionPlaceholderView(questionId: id)
                    case .exam:
                        ExamPlaceholderView()
                    case .result(let score):
                        ResultPlaceholderView(score: score)
                    case .profile:
                        ProfilePlaceholderView()
                    }
                }
        }
        .environmentObject(navStack)
    }
}

private struct DashboardPlaceholderView: View {
    var body: some View {
        Text("Dashboard")
    }
}

private struct CategoryPlaceholderView: View {
    let categoryId: String
    var body: some View {
        Text("Category: \(categoryId)")
    }
}

private struct QuestionPlaceholderView: View {
    let questionId: String
    var body: some View {
        Text("Question: \(questionId)")
    }
}

private struct ExamPlaceholderView: View {
    var body: some View {
        Text("Exam")
    }
}

private struct ResultPlaceholderView: View {
    let score: Double
    var body: some View {
        Text("Result: \(score)")
    }
}

private struct ProfilePlaceholderView: View {
    var body: some View {
        Text("Profile")
    }
}