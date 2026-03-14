import Foundation

enum ReadinessLevel: Int, Codable, Comparable {
    case beginner = 0
    case intermediate = 1
    case advanced = 2
    case expert = 3
    
    var displayName: String {
        switch self {
        case .beginner:
            return NSLocalizedString("readiness.level.beginner", comment: "")
        case .intermediate:
            return NSLocalizedString("readiness.level.intermediate", comment: "")
        case .advanced:
            return NSLocalizedString("readiness.level.advanced", comment: "")
        case .expert:
            return NSLocalizedString("readiness.level.expert", comment: "")
        }
    }
    
    var emoji: String {
        switch self {
        case .beginner: return "🌱"
        case .intermediate: return "📚"
        case .advanced: return "⚡"
        case .expert: return "🏆"
        }
    }
    
    var progressColor: Color {
        switch self {
        case .beginner: return Color(.systemRed)
        case .intermediate: return Color(.systemOrange)
        case .advanced: return Color(.systemYellow)
        case .expert: return Color(.systemGreen)
        }
    }
    
    static func from(percentage: Int) -> ReadinessLevel {
        switch percentage {
        case 0..<50: return .beginner
        case 50..<75: return .intermediate
        case 75..<90: return .advanced
        default: return .expert
        }
    }
    
    static func < (lhs: ReadinessLevel, rhs: ReadinessLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}