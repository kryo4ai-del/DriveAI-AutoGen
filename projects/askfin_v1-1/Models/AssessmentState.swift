import Foundation

enum AssessmentState: Equatable {
    case idle
    case loading
    case inProgress
    case processing
    case completed
    case error(String)
    
    var isActive: Bool {
        switch self {
        case .inProgress, .loading, .processing:
            return true
        default:
            return false
        }
    }
}