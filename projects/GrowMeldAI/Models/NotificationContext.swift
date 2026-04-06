enum NotificationContext {
    case examCompletion
    case streakMilestone(days: Int)
    case categoryMilestone(category: String)
    case dailyReminder
}

func content(for context: NotificationContext) -> (title: String, body: String) {
    let isGerman = Locale.current.language.languageCode?.identifier == "de"
    
    switch context {
    case .examCompletion:
        return isGerman
            ? (title: "Großartig! 🎉", body: "...")
            : (title: "Great job! 🎉", body: "...")
    
    case .streakMilestone(let days):
        return isGerman
            ? (title: "🔥 \(days)-Tage-Serie!", body: "...")
            : (title: "🔥 \(days)-day streak!", body: "...")
    
    case .categoryMilestone(let category):
        return isGerman
            ? (title: "✅ \(category) abgeschlossen!", body: "...")
            : (title: "✅ \(category) completed!", body: "...")
    
    case .dailyReminder:
        return isGerman
            ? (title: "📚 Lernzeit!", body: "...")
            : (title: "📚 Learning time!", body: "...")
    }
}

// Safe usage:
let (title, body) = NotificationContentBuilder.content(for: .streakMilestone(days: 3))