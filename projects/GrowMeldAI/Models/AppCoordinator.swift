import SwiftUI
import Foundation

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

    func handleExamResult(_ result: GrowMeldExamResult) {
        navigate(to: .examResult(result))
        recordExamResult(result)
    }

    private func recordExamResult(_ result: GrowMeldExamResult) {
        var results = loadStoredExamResults()
        results.append(result)
        saveExamResults(results)
    }

    // MARK: - Persistence

    private static let examResultsKey = "com.growmeld.examResults"

    func loadStoredExamResults() -> [GrowMeldExamResult] {
        guard let data = UserDefaults.standard.data(forKey: Self.examResultsKey) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([GrowMeldExamResult].self, from: data)) ?? []
    }

    private func saveExamResults(_ results: [GrowMeldExamResult]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(results) else { return }
        UserDefaults.standard.set(data, forKey: Self.examResultsKey)
    }
}