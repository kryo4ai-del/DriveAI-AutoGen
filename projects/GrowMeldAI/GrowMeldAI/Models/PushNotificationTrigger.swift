import Foundation

/// Event types that trigger consent requests at moments of value
enum PushNotificationTrigger: Hashable, Codable {
    case examPassed(score: Int)
    case examFailed
    case streakMilestone(days: Int)
    
    // MARK: - UI Properties
    
    var headline: String {
        switch self {
        case .examPassed(let score):
            return "🎉 Glückwunsch! Du hast bestanden!"
        case .examFailed:
            return "📝 Versuch es nächstes Mal!"
        case .streakMilestone(let days):
            return "🔥 \(days)-Tage Streak!"
        }
    }
    
    var description: String {
        switch self {
        case .examPassed:
            return "Möchtest du Benachrichtigungen für zukünftige Prüfungen bekommen?"
        case .examFailed:
            return "Benachrichtigungen helfen dir, motiviert zu bleiben."
        case .streakMilestone(let days):
            return "Lass dich erinnern, damit dein \(days)-Tage Streak nicht unterbrochen wird."
        }
    }
    
    var systemIcon: String {
        switch self {
        case .examPassed:
            return "checkmark.circle.fill"
        case .examFailed:
            return "arrow.counterclockwise"
        case .streakMilestone:
            return "flame.fill"
        }
    }
    
    // MARK: - Storage
    
    var identifier: String {
        switch self {
        case .examPassed:
            return "trigger.examPassed"
        case .examFailed:
            return "trigger.examFailed"
        case .streakMilestone(let days):
            return "trigger.streakMilestone.\(days)"
        }
    }
}

// MARK: - Equatable, Hashable conformance (for SwiftUI state management)
extension PushNotificationTrigger: Equatable {
    static func == (lhs: PushNotificationTrigger, rhs: PushNotificationTrigger) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}