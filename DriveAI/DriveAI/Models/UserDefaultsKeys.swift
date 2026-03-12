import SwiftUI
import Combine

// MARK: - SettingsViewModel

final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedLanguage: String
    @Published var notificationsEnabled: Bool
    @Published var theme: AppTheme

    // MARK: - Initializer
    init() {
        (selectedLanguage, notificationsEnabled, theme) = loadUserDefaults()
    }
    
    // MARK: - UserDefaults Loading
    private func loadUserDefaults() -> (String, Bool, AppTheme) {
        let selectedLang = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedLanguage) ?? Language.de.rawValue
        let notificationsEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        
        let storedTheme = UserDefaults.standard.string(forKey: UserDefaultsKeys.appTheme)
        let theme = AppTheme(rawValue: storedTheme ?? AppTheme.light.rawValue) ?? .light

        return (selectedLang, notificationsEnabled, theme)
    }

    // MARK: - Business Logic
    func toggleNotifications() {
        notificationsEnabled.toggle()
        UserDefaults.standard.set(notificationsEnabled, forKey: UserDefaultsKeys.notificationsEnabled)
        // Placeholder for future notification settings logic
    }

    func changeLanguage(to language: String) {
        selectedLanguage = language
        UserDefaults.standard.set(language, forKey: UserDefaultsKeys.selectedLanguage)
        // Placeholder for future language change logic
    }

    func changeTheme(to newTheme: AppTheme) {
        theme = newTheme
        UserDefaults.standard.set(newTheme.rawValue, forKey: UserDefaultsKeys.appTheme)
        // Placeholder for future theme change handling
    }
}

// MARK: - AppTheme Enum

enum AppTheme: String, CaseIterable, Identifiable {
    case light
    case dark
    
    var id: String { rawValue }
}

// MARK: - Language Enum

enum Language: String, CaseIterable {
    case de = "de" // German
    case en = "en" // English
    // Additional languages can be added here
}

// MARK: - UserDefaultsKeys Struct

struct UserDefaultsKeys {
    static let selectedLanguage = "selectedLanguage"
    static let notificationsEnabled = "notificationsEnabled"
    static let appTheme = "appTheme"
}