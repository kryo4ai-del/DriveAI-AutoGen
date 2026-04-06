import Foundation
import CryptoKit

enum BackupValidationError: Error {
    case invalidChecksum
    case missingRequiredFields
    case corruptedData
    case versionMismatch
}
