import Foundation

// MARK: - Service Protocols / Stubs (if not defined elsewhere)

// These are referenced but may not expose `.shared` unambiguously.
// Provide explicit type annotations to resolve contextual ambiguity.

@MainActor
final class AppContainer {
    static let shared = AppContainer()

    let dataService: LocalDataService
    let analyticsService: AnalyticsService
    let preferencesService: UserPreferencesService
    private(set) lazy var coordinator: AppCoordinator = AppCoordinator(
        dataService: dataService,
        preferencesService: preferencesService
    )

    init() {
        let data: LocalDataService = LocalDataService.shared
        let analytics: AnalyticsService = AnalyticsService.shared
        let prefs: UserPreferencesService = UserPreferencesService.shared

        self.dataService = data
        self.analyticsService = analytics
        self.preferencesService = prefs
    }
}

@MainActor
let appContainer = AppContainer.shared