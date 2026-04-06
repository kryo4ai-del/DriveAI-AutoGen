import SwiftUI
import Foundation

@MainActor
final class Router: ObservableObject {
    @Published var path: [Destination] = []

    enum Destination: Hashable {
        case onboarding
        case dashboard
        case questions(categoryId: String)
        case exam
        case profile
        case result(score: Int, total: Int, passed: Bool)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .onboarding:
                hasher.combine(0)
            case .dashboard:
                hasher.combine(1)
            case .questions(let categoryId):
                hasher.combine(2)
                hasher.combine(categoryId)
            case .exam:
                hasher.combine(3)
            case .profile:
                hasher.combine(4)
            case .result(let score, let total, let passed):
                hasher.combine(5)
                hasher.combine(score)
                hasher.combine(total)
                hasher.combine(passed)
            }
        }

        static func == (lhs: Destination, rhs: Destination) -> Bool {
            switch (lhs, rhs) {
            case (.onboarding, .onboarding):
                return true
            case (.dashboard, .dashboard):
                return true
            case (.questions(let a), .questions(let b)):
                return a == b
            case (.exam, .exam):
                return true
            case (.profile, .profile):
                return true
            case (.result(let s1, let t1, let p1), .result(let s2, let t2, let p2)):
                return s1 == s2 && t1 == t2 && p1 == p2
            default:
                return false
            }
        }
    }

    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeAll()
    }
}