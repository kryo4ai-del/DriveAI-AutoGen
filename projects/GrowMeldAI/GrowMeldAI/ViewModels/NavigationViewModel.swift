import SwiftUI
import Combine

final class NavigationViewModel: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: AppRoute?

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupNavigationObservation()
    }

    private func setupNavigationObservation() {
        $navigationPath
            .sink { [weak self] _ in
                self?.presentedSheet = nil
            }
            .store(in: &cancellables)
    }

    func navigate(to route: AppRoute) {
        navigationPath.append(route)
    }

    func presentSheet(route: AppRoute) {
        presentedSheet = route
    }

    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}