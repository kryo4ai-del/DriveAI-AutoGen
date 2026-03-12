import Foundation

struct UserSettings {
    let notificationsEnabled: Bool
    let language: String
    
    init(notificationsEnabled: Bool = true, language: String = "de") {
        self.notificationsEnabled = notificationsEnabled
        self.language = language
    }
    
    func with(notificationsEnabled: Bool? = nil, language: String? = nil) -> UserSettings {
        return UserSettings(
            notificationsEnabled: notificationsEnabled ?? self.notificationsEnabled,
            language: language ?? self.language
        )
    }
}