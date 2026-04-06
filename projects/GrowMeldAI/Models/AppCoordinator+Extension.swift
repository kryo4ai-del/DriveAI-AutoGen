import Foundation
import SwiftUI

// MARK: - AppRoute

enum GrowMeldAppRoute: Hashable {
    case home
    case exam
    case examResult(ExamResultPayload)
    case settings
    case progress
    case onboarding
}

// MARK: - ExamResultPayload

struct ExamResultPayload: Hashable, Codable {
    let id: UUID
    let score: Int
    let totalQuestions: Int
    let passed: Bool
    let date: Date
    let subject: String

    init(
        id: UUID = UUID(),
        score: Int,
        totalQuestions: Int,
        passed: Bool,
        date: Date = Date(),
        subject: String = ""
    ) {
        self.id = id
        self.score = score
        self.totalQuestions = totalQuestions
        self.passed = passed
        self.date = date
        self.subject = subject
    }

    var percentageScore: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }
}

// MARK: - AppCoordinator

@MainActor
final class AppCoordinator: ObservableObject {

    // MARK: - Published State

    @Published var navigationPath: [GrowMeldAppRoute] = []
    @Published var currentRoute: GrowMeldAppRoute = .home
    @Published var isPresenting: Bool = false
    @Published var presentedRoute: GrowMeldAppRoute? = nil

    // MARK: - Navigation

    func navigate(to route: GrowMeldAppRoute) {
        navigationPath.append(route)
        currentRoute = route
    }

    func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
        currentRoute = navigationPath.last ?? .home
    }

    func navigateToRoot() {
        navigationPath.removeAll()
        currentRoute = .home
    }

    func present(_ route: GrowMeldAppRoute) {
        presentedRoute = route
        isPresenting = true
    }

    func dismissPresented() {
        isPresenting = false
        presentedRoute = nil
    }

    // MARK: - Route Handling

    func handleRoute(_ route: GrowMeldAppRoute) {
        switch route {
        case .home:
            navigateToRoot()
        case .exam:
            navigate(to: .exam)
        case .examResult(let result):
            handleExamResult(result)
        case .settings:
            navigate(to: .settings)
        case .progress:
            navigate(to: .progress)
        case .onboarding:
            navigate(to: .onboarding)
        }
    }

    // MARK: - Exam Result Handling

    func handleExamResult(_ result: ExamResultPayload) {
        navigate(to: .examResult(result))
        recordExamResult(result)
    }

    private func recordExamResult(_ result: ExamResultPayload) {
        var results = loadStoredExamResults()
        results.append(result)
        saveExamResults(results)
    }

    // MARK: - Persistence (UserDefaults + Codable)

    private static let examResultsKey = "com.growmeld.examResults"

    func loadStoredExamResults() -> [ExamResultPayload] {
        guard
            let data = UserDefaults.standard.data(forKey: Self.examResultsKey),
            let results = try? JSONDecoder().decode([ExamResultPayload].self, from: data)
        else {
            return []
        }
        return results
    }

    private func saveExamResults(_ results: [ExamResultPayload]) {
        guard let data = try? JSONEncoder().encode(results) else { return }
        UserDefaults.standard.set(data, forKey: Self.examResultsKey)
    }

    func clearExamResults() {
        UserDefaults.standard.removeObject(forKey: Self.examResultsKey)
    }

    // MARK: - Deep Link Handling

    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        switch components.host {
        case "home":
            handleRoute(.home)
        case "exam":
            handleRoute(.exam)
        case "settings":
            handleRoute(.settings)
        case "progress":
            handleRoute(.progress)
        default:
            break
        }
    }
}