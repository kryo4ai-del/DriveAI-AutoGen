// Shared/Extensions/OverallStats+EmotionalFeedback.swift
import Foundation

extension OverallStats {
    var emotionalFeedback: String {
        let percentage = Int(accuracy * 100)

        switch percentage {
        case 90...100:
            return "Fantastisch! Du meisterst die Themen. 🎉"
        case 80..<90:
            return "Sehr gut! Weiter so, du bist auf einem guten Weg. 👍"
        case 70..<80:
            return "Gut! Mit etwas mehr Übung wirst du noch besser. 💪"
        case 60..<70:
            return "Es geht voran! Konzentriere dich auf deine schwächeren Themen. 📚"
        case 50..<60:
            return "Nicht schlecht, aber noch Luft nach oben. 📈"
        case 0..<50:
            return "Keine Sorge! Jede Frage ist eine Chance zu lernen. 🌱"
        default:
            return "Statistiken werden berechnet..."
        }
    }

    var encouragement: String {
        let streak = self.streak

        if streak >= 7 {
            return "Du hast eine beeindruckende Lernsträhne! 🏆"
        } else if streak >= 3 {
            return "Super! Du bleibst dran. 👏"
        } else if streak >= 1 {
            return "Jeder Tag zählt. Du schaffst das! 💪"
        } else {
            return "Beginne heute mit deiner Lernreise! 🚀"
        }
    }
}