struct NotificationContentBuilder {
    private static var isGerman: Bool {
        Locale.current.language.languageCode?.identifier == "de"
    }
    
    static func content(for trigger: NotificationTrigger, context: [String: Any]? = nil) -> (title: String, body: String) {
        switch trigger {
        case .examCompletion:
            return isGerman
                ? (title: "Großartig! 🎉", body: "Du hast Deine erste Prüfung abgeschlossen.")
                : (title: "Great job! 🎉", body: "You completed your first exam.")
        
        case .streakMilestone:
            let days = (context?["days"] as? Int) ?? 3
            return isGerman
                ? (title: "🔥 \(days)-Tage-Serie!", body: "Du lernst kontinuierlich!")
                : (title: "🔥 \(days)-day streak!", body: "You're learning consistently!")
        
        case .categoryMilestone:
            let category = (context?["category"] as? String) ?? "Kategorie"
            return isGerman
                ? (title: "✅ \(category) abgeschlossen!", body: "Nächste freigeschalten.")
                : (title: "✅ \(category) completed!", body: "Next unlocked.")
        
        case .dailyReminder:
            return isGerman
                ? (title: "📚 Lernzeit!", body: "Deine Lernsession wartet.")
                : (title: "📚 Learning time!", body: "Your session awaits.")
        }
    }
}