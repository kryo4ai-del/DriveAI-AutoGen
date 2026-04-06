import Foundation
import SwiftUI

enum MasteryLevel: String, Codable {
    case beginner
    case elementary
    case intermediate
    case advanced
    case expert

    var label: String {
        switch self {
        case .beginner: return "Anfänger"
        case .elementary: return "Grundkenntnisse"
        case .intermediate: return "Fortgeschritten"
        case .advanced: return "Erfahren"
        case .expert: return "Experte"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .beginner: return "Anfänger-Niveau"
        case .elementary: return "Grundkenntnisse-Niveau"
        case .intermediate: return "Fortgeschrittenes Niveau"
        case .advanced: return "Erfahrenes Niveau"
        case .expert: return "Experten-Niveau"
        }
    }

    var color: Color {
        switch self {
        case .beginner: return .red
        case .elementary: return .orange
        case .intermediate: return .yellow
        case .advanced: return .blue
        case .expert: return .green
        }
    }
}

struct Category: Codable {
    let id: String
    let name: String
}

struct CategoryStrength: Codable {
    let category: Category
    let accuracy: Double
    let masteryLevel: MasteryLevel
    let questionCount: Int

    var accuracyPercentage: Int {
        Int((accuracy * 100).rounded())
    }

    var accessibilityLabel: String {
        "\(category.name), \(masteryLevel.label), \(accuracyPercentage) Prozent"
    }

    var accessibilityHint: String {
        "Du hast \(questionCount) Fragen beantwortet. Dein Können: \(masteryLevel.label)."
    }
}