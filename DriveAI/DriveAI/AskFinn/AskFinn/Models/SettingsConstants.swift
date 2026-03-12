import Foundation

// Protocol for user settings service
protocol UserSettingsService {
    func loadSettings() -> (notificationsEnabled: Bool, language: String, darkModeEnabled: Bool)
    func saveSettings(notificationsEnabled: Bool, language: String, darkModeEnabled: Bool)
}

// Implementation of the UserSettingsService using UserDefaults
class UserDefaultsSettingsService: UserSettingsService {
    func loadSettings() -> (notificationsEnabled: Bool, language: String, darkModeEnabled: Bool) {
        let notificationsEnabled = UserDefaults.standard.bool(forKey: SettingsConstants.notificationsKey)
        let language = UserDefaults.standard.string(forKey: SettingsConstants.languageKey) ?? SettingsConstants.defaultLanguage
        let darkModeEnabled = UserDefaults.standard.bool(forKey: SettingsConstants.darkModeKey)
        return (notificationsEnabled, language, darkModeEnabled)
    }

    func saveSettings(notificationsEnabled: Bool, language: String, darkModeEnabled: Bool) {
        UserDefaults.standard.set(notificationsEnabled, forKey: SettingsConstants.notificationsKey)
        UserDefaults.standard.set(language, forKey: SettingsConstants.languageKey)
        UserDefaults.standard.set(darkModeEnabled, forKey: SettingsConstants.darkModeKey)
    }
}

// Constants for defining Settings
struct SettingsConstants {
    static let notificationsKey = "notificationsEnabled"
    static let languageKey = "language"
    static let darkModeKey = "darkModeEnabled"
    static let defaultLanguage = "Deutsch"
}
