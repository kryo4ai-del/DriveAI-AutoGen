import Foundation

@MainActor
final class AppContainer {
    static let shared = AppContainer()

    let dataService: LocalDataService
    let analyticsService: AnalyticsService
    let preferencesService: UserPreferencesService
    private(set) lazy var coordinator: AppCoordinator = AppCoordinator(
        dataService: self.dataService,
        preferencesService: self.preferencesService
    )

    init() {
        self.dataService = LocalDataService.shared
        self.analyticsService = AnalyticsService.shared
        self.preferencesService = UserPreferencesService.shared
    }
}

@MainActor
let appContainer = AppContainer.shared