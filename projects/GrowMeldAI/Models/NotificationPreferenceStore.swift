// Services/NotificationPreferenceStore.swift

final class NotificationPreferenceStore {
    private let userDefaults = UserDefaults.standard
    private let permissionStatusKey = "notificationPermissionStatus"
    private let isEnabledKey = "notificationIsEnabled"
    
    var isEnabled: Bool {
        userDefaults.bool(forKey: isEnabledKey)
    }
    
    func setIsEnabled(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: isEnabledKey)
    }
    
    @MainActor
    func setPermissionStatus(_ status: UNAuthorizationStatus) async {
        let statusRawValue = status.rawValue
        userDefaults.set(statusRawValue, forKey: permissionStatusKey)
    }
    
    func getPermissionStatus() -> UNAuthorizationStatus {
        let rawValue = userDefaults.integer(forKey: permissionStatusKey)
        return UNAuthorizationStatus(rawValue: rawValue) ?? .notDetermined
    }
}

// Models/NotificationPreference.swift
