import Foundation

extension CategoryStrength {
    var accessibilityLabel: String {
        "\(category.name): \(masteryLevel.label)"
    }

    var accessibilityHint: String {
        "Genauigkeit: \(accuracyPercentage) Prozent aus \(questionCount) Versuchen"
    }

    var accessibilityValue: String? {
        "\(accuracyPercentage)%"
    }
}

extension LearningGap {
    var accessibilityLabel: String {
        "\(category.name): \(gapSeverity.label) Lücke"
    }

    var accessibilityHint: String {
        var hint = "Diese Kategorie braucht Aufmerksamkeit. "
        hint += "Empfohlene Wiederholungen: \(recommendedPracticeCount). "
        if let daysSince = daysSinceReview {
            hint += "Zuletzt vor \(daysSince) Tagen überprüft."
        } else {
            hint += "Noch nicht überprüft."
        }
        if isOverdue {
            hint += " Zeitig zu überprüfen."
        }
        return hint
    }
}

extension DiagnosticResult {
    var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "Diagnose vom \(formatter.string(from: date))"
    }

    var accessibilitySummary: String {
        """
        Mastery Coverage: \(Int(masteryCoverage * 100)) Prozent.
        Gesamtgenauigkeit: \(Int(overallAccuracy * 100)) Prozent.
        Kritische Lücken: \(gapCount(severity: .critical)).
        \(efficacyMessage)
        """
    }
}