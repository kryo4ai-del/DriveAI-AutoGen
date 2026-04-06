import SwiftUI

enum Route {
    case onboarding
    case home
    case categoryList
    case categoryDetail(id: UUID)
    case quiz(categoryId: UUID)
    case examSimulation
    case results(result: QuizResult)
    case profile
    case questionDetail(id: UUID)
}

struct QuizResult {
    let score: Int
    let total: Int
    let categoryId: UUID?
}

struct RouteView: View {
    let route: Route

    var body: some View {
        switch route {
        case .onboarding:
            OnboardingView()
        case .home:
            DashboardView()
        case .categoryList:
            CategoryListView()
        case .categoryDetail(let id):
            CategoryDetailFallbackView(categoryId: id)
        case .quiz(let categoryId):
            QuizSessionFallbackView(categoryId: categoryId)
        case .examSimulation:
            ExamSimulationView()
        case .results(let result):
            ResultsFallbackView(result: result)
        case .profile:
            ProfileView()
        case .questionDetail(let id):
            QuestionDetailFallbackView(questionId: id)
        }
    }
}

struct CategoryDetailFallbackView: View {
    let categoryId: UUID
    var body: some View {
        Text("Category Detail: \(categoryId.uuidString)")
            .navigationTitle("Category")
    }
}

struct QuizSessionFallbackView: View {
    let categoryId: UUID
    var body: some View {
        Text("Quiz Session: \(categoryId.uuidString)")
            .navigationTitle("Quiz")
    }
}

struct ResultsFallbackView: View {
    let result: QuizResult
    var body: some View {
        VStack(spacing: 16) {
            Text("Results")
                .font(.largeTitle)
                .bold()
            Text("Score: \(result.score) / \(result.total)")
                .font(.title2)
        }
        .navigationTitle("Results")
    }
}

struct QuestionDetailFallbackView: View {
    let questionId: UUID
    var body: some View {
        Text("Question Detail: \(questionId.uuidString)")
            .navigationTitle("Question")
    }
}