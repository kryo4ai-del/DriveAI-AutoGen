import Foundation

// MARK: - Service Protocols / Stubs (if not defined elsewhere)

// These are referenced but may not expose `.shared` unambiguously.
// Provide explicit type annotations to resolve contextual ambiguity.

@MainActor
final class AppContainer {
    static let shared = AppContainer()

    let dataService: any LocalDataServiceProtocol
    let analyticsService: any AnalyticsServiceProtocol
    let preferencesService: any UserPreferencesServiceProtocol
    private(set) lazy var coordinator: any AppCoordinatorProtocol = makeCoordinator()

    private func makeCoordinator() -> any AppCoordinatorProtocol {
        return MainAppCoordinator(
            dataService: dataService,
            preferencesService: preferencesService
        )
    }

    init() {
        self.dataService = LocalDataStore.shared
        self.analyticsService = AnalyticsTracker.shared
        self.preferencesService = UserPreferences.shared
    }
}

// MARK: - Protocols

protocol LocalDataServiceProtocol: AnyObject {
    static var shared: Self { get }
}

protocol AnalyticsServiceProtocol: AnyObject {
    static var shared: Self { get }
}

protocol UserPreferencesServiceProtocol: AnyObject {
    static var shared: Self { get }
}

protocol AppCoordinatorProtocol: AnyObject {}

// MARK: - Concrete Implementations

@MainActor
final class LocalDataStore: LocalDataServiceProtocol {
    static let shared = LocalDataStore()
    private init() {}
}

@MainActor
final class AnalyticsTracker: AnalyticsServiceProtocol {
    static let shared = AnalyticsTracker()
    private init() {}
}

@MainActor
final class UserPreferences: UserPreferencesServiceProtocol {
    static let shared = UserPreferences()
    private init() {}
}

@MainActor
final class MainAppCoordinator: AppCoordinatorProtocol {
    let dataService: any LocalDataServiceProtocol
    let preferencesService: any UserPreferencesServiceProtocol

    init(dataService: any LocalDataServiceProtocol, preferencesService: any UserPreferencesServiceProtocol) {
        self.dataService = dataService
        self.preferencesService = preferencesService
    }
}

@MainActor
let appContainer = AppContainer.shared