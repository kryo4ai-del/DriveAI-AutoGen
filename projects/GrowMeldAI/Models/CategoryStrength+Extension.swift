// MARK: - Models/CategoryStrength+Accessibility.swift

extension CategoryStrength {
    /// Accessible label for VoiceOver announcements
    var accessibilityLabel: String {
        "\(category.name): \(masteryLevel.label)"
    }
    
    /// Descriptive hint explaining the accuracy and progress
    var accessibilityHint: String {
        "Genauigkeit: \(accuracyPercentage) Prozent aus \(questionCount) Versuchen"
    }
    
    /// Value for progress indicators
    var accessibilityValue: String? {
        "\(accuracyPercentage)%"
    }
}

// MARK: - Models/LearningGap+Accessibility.swift

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

// MARK: - Models/DiagnosticResult+Accessibility.swift

extension DiagnosticResult {
    var accessibilityLabel: String {
        "Diagnose vom \(timestamp.formatted(date: .abbreviated, time: .omitted))"
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