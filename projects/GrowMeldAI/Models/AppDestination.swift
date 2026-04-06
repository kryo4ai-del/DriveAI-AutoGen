import Foundation

struct ExamResult: Identifiable, Hashable {
    let id: UUID
}

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