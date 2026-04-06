// Shared/Localization/Strings.swift
enum L10n {
    enum Onboarding {
        static let title = NSLocalizedString(
            "onboarding.title",
            value: "Willkommen zu DriveAI",
            comment: "Onboarding welcome title"
        )
        static let subtitle = NSLocalizedString(
            "onboarding.subtitle",
            value: "Bereite dich optimal auf deine Führerscheinprüfung vor",
            comment: "Onboarding subtitle"
        )
    }
    
    enum Quiz {
        static let nextQuestion = NSLocalizedString(
            "quiz.nextQuestion",
            value: "Nächste Frage",
            comment: "Button to advance to next question"
        )
        static let correct = NSLocalizedString(
            "quiz.correct",
            value: "✓ Richtig!",
            comment: "Correct answer feedback"
        )
        static let incorrect = NSLocalizedString(
            "quiz.incorrect",
            value: "✗ Falsch",
            comment: "Incorrect answer feedback"
        )
    }
}

// Usage in views:
Text(L10n.Onboarding.title)
Text(L10n.Quiz.nextQuestion)