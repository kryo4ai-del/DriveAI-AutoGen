// Route.swift
import SwiftUI

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
            CategoryDetailView(categoryId: id)
        case .quiz(let categoryId):
            QuizSessionView(categoryId: categoryId)
        case .examSimulation:
            ExamSimulationView()
        case .results(let result):
            ResultsView(result: result)
        case .profile:
            ProfileView()
        case .questionDetail(let id):
            QuestionDetailView(questionId: id)
        }
    }
}
