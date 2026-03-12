import SwiftUI
import Combine

// MARK: - UserDefaultsKeys Struct

struct UserDefaultsKeys {
    static let selectedLanguage = "selectedLanguage"
    static let notificationsEnabled = "notificationsEnabled"
    static let appTheme = "appTheme"
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
