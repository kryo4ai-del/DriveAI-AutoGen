enum SettingsError: Error {
    case loadError(String)
    case saveError(String)
}

// Update the load and save methods to throw errors
class UserDefaultsSettingsService: UserSettingsService {
    func loadSettings() throws -> (notificationsEnabled: Bool, language: String, darkModeEnabled: Bool) {
        // If any load operation fails, throw an appropriate error
    }
    
    func saveSettings(notificationsEnabled: Bool, language: String, darkModeEnabled: Bool) throws {
        // If any save operation fails, throw an appropriate error
    }
}