import Foundation

/// Exam state machine—prevents invalid transitions
enum ExamStatus: String, Codable, Equatable {
    case notStarted
    case inProgress
    case paused
    case completed
}
