import Foundation

enum AppDestination: Hashable {
    case home
    case questionCategory(String)
    case examSimulation
    case examResults(ExamResult)
    case profile

    func hash(into hasher: inout Hasher) {
        switch self {
        case .home:
            hasher.combine(0)
        case .questionCategory(let category):
            hasher.combine(1)
            hasher.combine(category)
        case .examSimulation:
            hasher.combine(2)
        case .examResults(let result):
            hasher.combine(3)
            hasher.combine(result.id)
        case .profile:
            hasher.combine(4)
        }
    }

    static func == (lhs: AppDestination, rhs: AppDestination) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home):
            return true
        case (.questionCategory(let a), .questionCategory(let b)):
            return a == b
        case (.examSimulation, .examSimulation):
            return true
        case (.examResults(let a), .examResults(let b)):
            return a.id == b.id
        case (.profile, .profile):
            return true
        default:
            return false
        }
    }
}

// MARK: - Minimal ExamResult model (if not defined elsewhere)

struct ExamResult: Identifiable, Hashable, Codable {
    let id: String
    let score: Int
    let totalQuestions: Int
    let correctAnswers: Int
    let dateTaken: Date
    let categoryName: String?

    init(
        id: String = UUID().uuidString,
        score: Int,
        totalQuestions: Int,
        correctAnswers: Int,
        dateTaken: Date = Date(),
        categoryName: String? = nil
    ) {
        self.id = id
        self.score = score
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.dateTaken = dateTaken
        self.categoryName = categoryName
    }
}