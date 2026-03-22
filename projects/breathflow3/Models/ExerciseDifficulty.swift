// Models/Exercise.swift
import Foundation

enum ExerciseDifficulty: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var colorKey: String {
        switch self {
        case .beginner: return "systemGreen"
        case .intermediate: return "systemOrange"
        case .advanced: return "systemRed"
        }
    }
}

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let category: ExerciseCategory
    let difficulty: ExerciseDifficulty
    let estimatedDuration: Int // minutes
    let questionCount: Int
    let icon: String // SF Symbol
    let color: String // Hex or named color
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, category, difficulty
        case estimatedDuration = "estimated_duration"
        case questionCount = "question_count"
        case icon, color
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
