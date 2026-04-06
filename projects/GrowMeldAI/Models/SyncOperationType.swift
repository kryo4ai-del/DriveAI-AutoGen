import Foundation

enum SyncOperationType: String, Codable {
    case updateProgress
    case updateProfile
    case deleteProgress
}

enum SyncStatus: String, Codable {
    case pending
    case inProgress
    case completed
    case failed
}