import CloudKit
import Foundation

enum CloudKitError: Error {
    case recordEncodingFailed
    case recordDecodingFailed
    case notAuthenticated
    case quotaExceeded
    case unknown(Error)
}
