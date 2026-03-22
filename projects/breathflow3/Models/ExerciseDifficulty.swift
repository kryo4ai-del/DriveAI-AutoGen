// Models/ExerciseDifficulty.swift
import Foundation

enum ExerciseDifficulty: String, Codable, CaseIterable, Sendable {
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
