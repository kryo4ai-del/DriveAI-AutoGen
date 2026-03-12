import Foundation

enum SettingsError: Error {
    case loadError(String)
    case saveError(String)
}
