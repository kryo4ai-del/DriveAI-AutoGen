import Foundation

enum MotivationalTier {
    case finalWeek
    case twoWeeks
    case monthPlus
    case unknownDate
    
    /// Determine tier based on days until exam
    static func tier(for daysUntilExam: Int) -> MotivationalTier {
        switch daysUntilExam {
        case 0...7:
            return .finalWeek
        case 8...14:
            return .twoWeeks
        case 15...:
            return .monthPlus
        default:
            return .unknownDate
        }
    }
}
