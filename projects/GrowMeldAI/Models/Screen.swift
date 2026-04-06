import SwiftUI
enum Screen: Hashable {
    case onboarding
    case home
    case questionList(categoryID: String)
    case question(categoryID: String, questionID: String)
    case examSimulation
    case examResult(score: Int, totalQuestions: Int)
    case profile
    
    // MARK: - Identifiable for NavigationStack
    var id: String {
        switch self {
        case .onboarding: return "onboarding"
        case .home: return "home"
        case .questionList(let id): return "questionList-\(id)"
        case .question(let catID, let qID): return "question-\(catID)-\(qID)"
        case .examSimulation: return "examSimulation"
        case .examResult(let score, let total): return "examResult-\(score)-\(total)"
        case .profile: return "profile"
        }
    }
}