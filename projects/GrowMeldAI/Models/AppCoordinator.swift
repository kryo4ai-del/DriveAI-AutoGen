// Models/AppCoordinator.swift
import SwiftUI

// MARK: - Supporting Types

enum QuestionMode: Hashable {
    case learning
    case practice
    case review
}

// MARK: - AppCoordinator

@MainActor
final class AppCoordinator: ObservableObject {

    // MARK: - Route

    enum Route: Hashable {
        case onboarding
        case dashboard
        case questions(categoryID: String?, mode: QuestionMode)
        case exam
        case examResults(String) // ExamResult ID
        case profile
        case categoryDetail(String) // Category ID
        case settings
    }

    // MARK: - Properties

    @Published var path: [Route] = []

    private let dataService: LocalDataService
    private let preferencesService: UserPreferencesService

    // MARK: - Init

    init(
        dataService: LocalDataService,
        preferencesService: UserPreferencesService
    ) {
        self.dataService = dataService
        self.preferencesService = preferencesService
    }

    // MARK: - Navigation

    func navigate(to route: Route) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeAll()
    }

    func replace(with route: Route) {
        if !path.isEmpty {
            path.removeLast()
        }
        path.append(route)
    }

    // MARK: - Destination Builder

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .onboarding:
            OnboardingPlaceholderView()

        case .dashboard:
            DashboardPlaceholderView()

        case .questions(let categoryID, let mode):
            QuestionSessionPlaceholderView(
                categoryID: categoryID,
                mode: mode
            )

        case .exam:
            ExamPlaceholderView()

        case .examResults(let resultID):
            ExamResultsPlaceholderView(resultID: resultID)

        case .profile:
            ProfilePlaceholderView()

        case .categoryDetail(let categoryID):
            CategoryDetailPlaceholderView(categoryID: categoryID)

        case .settings:
            SettingsPlaceholderView(preferencesService: preferencesService)
        }
    }
}

// MARK: - Service Stubs (minimal working versions if not defined elsewhere)

final class LocalDataService: ObservableObject {
    static let shared = LocalDataService()
    init() {}
}

final class UserPreferencesService: ObservableObject {
    static let shared = UserPreferencesService()

    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Placeholder Views

private struct OnboardingPlaceholderView: View {
    var body: some View {
        Text("Onboarding")
            .navigationTitle("Welcome")
    }
}

private struct DashboardPlaceholderView: View {
    var body: some View {
        Text("Dashboard")
            .navigationTitle("Dashboard")
    }
}

private struct QuestionSessionPlaceholderView: View {
    let categoryID: String?
    let mode: QuestionMode

    var body: some View {
        Text("Questions – mode: \(String(describing: mode))")
            .navigationTitle("Questions")
    }
}

private struct ExamPlaceholderView: View {
    var body: some View {
        Text("Exam")
            .navigationTitle("Exam")
    }
}

private struct ExamResultsPlaceholderView: View {
    let resultID: String

    var body: some View {
        Text("Exam Results – \(resultID)")
            .navigationTitle("Results")
    }
}

private struct ProfilePlaceholderView: View {
    var body: some View {
        Text("Profile")
            .navigationTitle("Profile")
    }
}

private struct CategoryDetailPlaceholderView: View {
    let categoryID: String

    var body: some View {
        Text("Category – \(categoryID)")
            .navigationTitle("Category")
    }
}

private struct SettingsPlaceholderView: View {
    let preferencesService: UserPreferencesService

    var body: some View {
        Text("Settings")
            .navigationTitle("Settings")
    }
}