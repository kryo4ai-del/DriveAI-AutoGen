import Foundation

enum PermissionState {
    case accepted(date: Date)
    case denied(date: Date, nextRetryDate: Date?)
}