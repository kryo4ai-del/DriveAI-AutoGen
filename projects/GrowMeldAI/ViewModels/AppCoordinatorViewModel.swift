import SwiftUI
import Combine

@MainActor
class AppCoordinatorViewModel: ObservableObject {
    @Published var navigationPath: [NavigationDestination] = []
    @Published var userState: UserState = .new

    enum UserState {
        case new
        case setup
        case ready
        case examInProgress
        case examComplete
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
        navigationPath = []
    }

    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

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
            return true
        }
    }
}