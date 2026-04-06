import Foundation

enum NotificationContext {
    case examCompletion
    case streakMilestone(days: Int)
    case categoryMilestone(category: String)
    case dailyReminder
}

enum NotificationContentBuilder {
    static func content(for context: NotificationContext) -> (title: String, body: String) {
        let isGerman = Locale.current.language.languageCode?.identifier == "de"

        switch context {
        case .examCompletion:
            return isGerman
                ? (title: "Großartig! 🎉", body: "Du hast die Prüfung abgeschlossen!")
                : (title: "Great job! 🎉", body: "You completed the exam!")

        case .streakMilestone(let days):
            return isGerman
                ? (title: "🔥 \(days)-Tage-Serie!", body: "Weiter so – du bist auf einem tollen Weg!")
                : (title: "🔥 \(days)-day streak!", body: "Keep it up – you're on a roll!")

        case .categoryMilestone(let category):
            return isGerman
                ? (title: "✅ \(category) abgeschlossen!", body: "Alle Fragen in dieser Kategorie gemeistert.")
                : (title: "✅ \(category) completed!", body: "You mastered all questions in this category.")

        case .dailyReminder:
            return isGerman
                ? (title: "📚 Lernzeit!", body: "Zeit für deine tägliche Lerneinheit.")
                : (title: "📚 Learning time!", body: "Time for your daily learning session.")
        }
    }
}