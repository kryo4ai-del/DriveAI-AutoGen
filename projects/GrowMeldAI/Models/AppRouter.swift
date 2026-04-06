// UI/Navigation/AppRouter.swift
@MainActor
class AppRouter: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    
    enum Route: Hashable {
        case onboarding
        case dashboard
        case quiz(categoryId: String)
        case examSimulation
        case examResult(ExamResult)
        case profile
    }
    
    private let validTransitions: [Route: [Route]] = [
        .onboarding: [.dashboard],
        .dashboard: [.quiz, .examSimulation, .profile],
        .examSimulation: [.examResult],
        .examResult: [.dashboard],
    ]
    
    func canNavigate(from: Route, to: Route) -> Bool {
        validTransitions[from]?.contains(to) ?? false
    }
}