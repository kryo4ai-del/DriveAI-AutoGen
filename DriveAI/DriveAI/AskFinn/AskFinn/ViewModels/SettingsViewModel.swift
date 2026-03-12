import SwiftUI
import Combine

enum SettingsUpdateType {
    case notificationsChanged
    case languageChanged
    case darkModeChanged
}

class SettingsViewModel: ObservableObject {
    var settingsChanged = PassthroughSubject<SettingsUpdateType, Never>()

    @Published var notificationsEnabled: Bool = false
    @Published var language: String = SettingsConstants.defaultLanguage
    @Published var darkModeEnabled: Bool = false
    @Published var errorMessage: String? = nil

    private var userSettingsService: UserSettingsService
    private var cancellables = Set<AnyCancellable>()

    init(settingsService: UserSettingsService = UserDefaultsSettingsService()) {
        self.userSettingsService = settingsService
        loadUserSettings()
    }

    private func loadUserSettings() {
        let settings = userSettingsService.loadSettings()
        notificationsEnabled = settings.notificationsEnabled
        language = settings.language
        darkModeEnabled = settings.darkModeEnabled
    }

    private func updateSettings() {
        userSettingsService.saveSettings(
            notificationsEnabled: notificationsEnabled,
            language: language,
            darkModeEnabled: darkModeEnabled
        )
    }

    func toggleNotifications() {
        notificationsEnabled.toggle()
        updateSettings()
        settingsChanged.send(.notificationsChanged)
    }

    func changeLanguage(to newLanguage: String) {
        language = newLanguage
        updateSettings()
        settingsChanged.send(.languageChanged)
    }

    func toggleDarkMode() {
        darkModeEnabled.toggle()
        updateSettings()
        settingsChanged.send(.darkModeChanged)
    }
}
