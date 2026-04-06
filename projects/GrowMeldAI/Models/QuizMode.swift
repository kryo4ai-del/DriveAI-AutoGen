import Foundation

// MARK: - Quiz Mode

enum QuizMode: String, Codable, Hashable, Sendable {
    case practice = "practice"
    case examSimulation = "examSimulation"
    
    var displayName: String {
        switch self {
        case .practice: return "Trainingsmodus"
        case .examSimulation: return "Prüfungssimulation"
        }
    }
    
    var questionCount: Int {
        switch self {
        case .practice: return 10
        case .examSimulation: return 30
        }
    }
    
    var durationSeconds: TimeInterval {
        switch self {
        case .practice: return 0
        case .examSimulation: return 60 * 60
        }
    }
    
    var passingScore: Int {
        75
    }
}

// MARK: - Session Answer

// MARK: - Quiz Session
