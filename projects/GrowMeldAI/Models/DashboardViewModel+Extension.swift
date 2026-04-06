import Foundation

extension DashboardViewModel {
    var categoryProgressAccessibilityLabel: String {
        "Dashboard Kategorien"
    }
}

extension DashboardViewModel.CategoryProgress {
    var accessibilityLabel: String {
        "\(category.displayName)"
    }

    var accessibilityValue: String {
        let percent = percentage > 0 ? Int(percentage) : 0
        return "\(correctAnswers) von \(totalQuestions) beantwortet, \(percent) Prozent korrekt"
    }

    var accessibilityHint: String {
        if percentage >= 80 {
            return "Gut vorbereitet. Doppeltippen zum Üben."
        } else if percentage >= 60 {
            return "Gute Fortschritte. Doppeltippen zum Üben."
        } else {
            return "Mehr Übung nötig. Doppeltippen zum Üben."
        }
    }
}