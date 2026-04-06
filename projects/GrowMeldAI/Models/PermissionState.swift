import Foundation

enum PermissionState {
    case notDetermined
    case permitted
    case authorized
    case denied
    case restricted
    case notAvailable
    case accepted(date: Date)
    case deniedWithRetry(date: Date, nextRetryDate: Date?)
}
