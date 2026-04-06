import SwiftUI

struct AppNavigation: View {
    @StateObject private var navStack = NavigationStackController()

    var body: some View {
        NavigationStack(path: $navStack.path) {
            DashboardPlaceholderView()
                .navigationDestination(for: AppNavigationPath.self) { route in
                    switch route {
                    case .categoryBrowser:
                        CategoryBrowserPlaceholderView()
                    case .questionFlow(let categoryId):
                        QuestionFlowPlaceholderView(categoryId: categoryId)
                    case .examMode:
                        ExamModePlaceholderView()
                    case .examResults(let score, let total, let passed):
                        ExamResultsPlaceholderView(score: score, total: total, passed: passed)
                    }
                }
        }
        .environmentObject(navStack)
    }
}

private struct DashboardPlaceholderView: View {
    var body: some View {
        Text("Dashboard")
            .navigationTitle("Dashboard")
    }
}

private struct CategoryBrowserPlaceholderView: View {
    var body: some View {
        Text("Category Browser")
            .navigationTitle("Categories")
    }
}

private struct QuestionFlowPlaceholderView: View {
    let categoryId: UUID
    var body: some View {
        Text("Question Flow: \(categoryId.uuidString)")
            .navigationTitle("Questions")
    }
}

private struct ExamModePlaceholderView: View {
    var body: some View {
        Text("Exam Mode")
            .navigationTitle("Exam")
    }
}

private struct ExamResultsPlaceholderView: View {
    let score: Int
    let total: Int
    let passed: Bool
    var body: some View {
        Text("Results: \(score)/\(total) — \(passed ? "Passed" : "Failed")")
            .navigationTitle("Results")
    }
}