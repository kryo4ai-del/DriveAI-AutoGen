import Foundation

// CrashlyticsManager - Firebase Crashlytics not available
class CrashlyticsManager {
    static let shared = CrashlyticsManager()
    func recordError(_ error: Error) {}
}
