enum Keys: String {
    case examDate = "com.driveai.examDate"
    case darkModeMode = "com.driveai.darkModeMode"  // Changed to avoid collision
    case notificationsEnabled = "com.driveai.notificationsEnabled"
}

enum DarkModeMode: String, Codable {
    case system   // Follow system (default)
    case light
    case dark
}

var darkModeMode: DarkModeMode {
    get {
        guard let rawValue = userDefaults.string(forKey: Keys.darkModeMode.rawValue) else {
            return .system  // Default
        }
        return DarkModeMode(rawValue: rawValue) ?? .system
    }
    set {
        userDefaults.set(newValue.rawValue, forKey: Keys.darkModeMode.rawValue)
    }
}

var isDarkModeEnabled: Bool {  // Deprecated, use darkModeMode
    get { darkModeMode == .dark }
    set { darkModeMode = newValue ? .dark : .light }
}

func reset() throws {
    userDefaults.removeObject(forKey: Keys.examDate.rawValue)
    userDefaults.removeObject(forKey: Keys.darkModeMode.rawValue)  // Explicit reset
    userDefaults.removeObject(forKey: Keys.notificationsEnabled.rawValue)
}