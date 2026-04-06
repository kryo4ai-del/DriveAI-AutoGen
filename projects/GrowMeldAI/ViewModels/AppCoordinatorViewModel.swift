import SwiftUI
import Combine

@MainActor
class AppCoordinatorViewModel: ObservableObject {
    @Published var navigationPath: NavigationPath = NavigationPath()
    @Published var userState: UserState = .new

    enum UserState {
        case new              // hasn't set exam date
        case setup            // onboarding flow
        case ready            // home/learning
        case examInProgress   // timed exam running
        case examComplete     // waiting to review results
    }

    enum NavigationDestination: Hashable {
        case onboarding
        case home
        case exam
        case examResults
        case settings
    }

    func navigate(to destination: NavigationDestination) {
        guard isValidTransition(from: userState, to: destination) else {
            assertionFailure("Invalid navigation")
            return
        }
        navigationPath.append(destination)
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }

    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    // MARK: - Private Helpers

    private func isValidTransition(from state: UserState, to destination: NavigationDestination) -> Bool {
        switch (state, destination) {
        case (.new, .onboarding):
            return true
        case (.setup, .onboarding):
            return true
        case (.setup, .home):
            return true
        case (.ready, .home):
            return true
        case (.ready, .exam):
            return true
        case (.ready, .settings):
            return true
        case (.examInProgress, .examResults):
            return true
        case (.examComplete, .home):
            return true
        case (.examComplete, .examResults):
            return true
        default:
            return true // Allow permissive navigation by default; tighten as needed
        }
    }
}