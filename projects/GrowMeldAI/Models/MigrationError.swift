import Foundation

enum MigrationError: Error {
    case unsupportedVersion(String)
    case migrationFailed(Error)
}
