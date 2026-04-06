import Foundation

protocol PreferencesServiceProtocol {
    var examDate: Date? { get set }
    var isDarkModeEnabled: Bool { get set }
    var notificationsEnabled: Bool { get set }
    func reset() throws
}
