// Presentation/Styles/MasteryFeedback.swift
import SwiftUI

struct MasteryFeedback {
    static func message(for score: Double, category: String) -> String {
        let level = masteryLevel(for: score)

        switch level {
        case .anfänger:
            return "Du bist noch Anfänger in \(category). Keine Sorge, mit jeder Frage wirst du besser!"
        case .fortgeschrittener:
            return "Gut gemacht! Du bist auf dem Weg zum Fortgeschrittenen in \(category)."
        case .experte:
            return "Sehr gut! Du bist fast ein Experte in \(category)."
        case .meister:
            return "Perfekt! Du bist ein Meister in \(category). Das schaffst du auch in der Prüfung!"
        }
    }

    static func masteryLevel(for score: Double) -> MasteryLevel {
        switch score {
        case 0..<50: return .anfänger
        case 50..<80: return .fortgeschrittener
        case 80..<95: return .experte
        default: return .meister
        }
    }

    enum MasteryLevel {
        case anfänger
        case fortgeschrittener
        case experte
        case meister
    }
}