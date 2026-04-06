import Foundation

enum AppDestination: Hashable {
    case home
    case questionCategory(String)
    case examSimulation
    case examResults(UUID, Int, Int, Date)
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
        case .examResults(let id, _, _, _):
            hasher.combine(3)
            hasher.combine(id)
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
        case (.examResults(let aId, _, _, _), .examResults(let bId, _, _, _)):
            return aId == bId
        case (.profile, .profile):
            return true
        default:
            return false
        }
    }
}