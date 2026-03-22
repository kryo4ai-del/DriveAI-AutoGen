import Foundation

struct BreathingExercise: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let category: ExerciseCategory
    let duration: Int // seconds
    let cycles: Int
    
    let emotionalOutcomes: [EmotionalOutcome]
    let microcopy: String
    
    let difficulty: DifficultyLevel
    let breathPattern: BreathPattern
    
    static func == (lhs: BreathingExercise, rhs: BreathingExercise) -> Bool {
        lhs.id == rhs.id
    }
}

enum ExerciseCategory: String, Codable, CaseIterable, Hashable {
    case calm = "Calm"
    case focus = "Focus"
    case energy = "Energy"
    case sleep = "Sleep"
    case stress = "Stress Relief"
    
    var icon: String {
        switch self {
        case .calm: return "leaf.fill"
        case .focus: return "target"
        case .energy: return "bolt.fill"
        case .sleep: return "moon.stars.fill"
        case .stress: return "heart.fill"
        }
    }
}

enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner, intermediate, advanced
    
    var displayName: String {
        rawValue.capitalized
    }
}
