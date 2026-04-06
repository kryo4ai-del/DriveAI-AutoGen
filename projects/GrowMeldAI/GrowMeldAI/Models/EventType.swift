import Foundation

enum EventType: String, Codable, CaseIterable, Hashable {
    // App lifecycle
    case appLaunched
    case appTerminated
    case appBackgrounded
    case appForegrounded
    
    // Onboarding
    case onboardingStarted
    case onboardingCompleted
    case examDateSet
    
    // Learning
    case quizStarted
    case questionViewed
    case questionAnswered
    case quizCompleted
    
    // Exam Simulation
    case examSimulationStarted
    case examSimulationCompleted
    
    // User Profile
    case userProfileViewed
    case settingsChanged
    case streakViewed
    
    // Engagement
    case notificationReceived
    case notificationActioned
    case reengagementTriggered
    
    var category: EventCategory {
        switch self {
        case .appLaunched, .appTerminated, .appBackgrounded, .appForegrounded:
            return .lifecycle
        case .onboardingStarted, .onboardingCompleted, .examDateSet:
            return .onboarding
        case .quizStarted, .questionViewed, .questionAnswered, .quizCompleted:
            return .learning
        case .examSimulationStarted, .examSimulationCompleted:
            return .exam
        case .userProfileViewed, .settingsChanged, .streakViewed:
            return .profile
        case .notificationReceived, .notificationActioned, .reengagementTriggered:
            return .engagement
        }
    }
    
    var priority: EventPriority {
        switch self {
        case .onboardingCompleted, .questionAnswered, .quizCompleted,
             .examSimulationCompleted, .quizStarted, .examSimulationStarted,
             .onboardingStarted:
            return .high
        case .appLaunched, .settingsChanged, .examDateSet:
            return .medium
        case .questionViewed, .userProfileViewed, .appTerminated, .streakViewed:
            return .low
        default:
            return .medium
        }
    }
    
    var shouldLogByDefault: Bool {
        switch self {
        case .appLaunched, .onboardingCompleted, .questionAnswered, .quizCompleted,
             .examSimulationCompleted, .quizStarted:
            return true
        case .questionViewed, .userProfileViewed, .appTerminated:
            return false
        default:
            return true
        }
    }
    
    var containsPotentialPII: Bool {
        switch self {
        case .settingsChanged, .examDateSet:
            return true
        default:
            return false
        }
    }
    
    var displayName: String {
        let camelCase = self.rawValue
        return camelCase
            .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
            .capitalized
    }
}

enum EventCategory: String, Codable, Hashable {
    case lifecycle
    case onboarding
    case learning
    case exam
    case profile
    case engagement
}

enum EventPriority: Int, Comparable, Codable, Hashable {
    case low = 1
    case medium = 2
    case high = 3
    
    static func < (lhs: EventPriority, rhs: EventPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}