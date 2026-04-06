struct NotificationContent {
    // MARK: - Accessible Notification Content
    
    /// Structured notification with screen reader support
    struct AccessibleNotification {
        let title: String
        let body: String
        let accessibilityLabel: String
        let accessibilityHint: String
        
        init(
            title: String,
            body: String,
            accessibilityLabel: String,
            accessibilityHint: String
        ) {
            self.title = title
            self.body = body
            self.accessibilityLabel = accessibilityLabel
            self.accessibilityHint = accessibilityHint
        }
    }
    
    static let notifications: [AccessibleNotification] = [
        AccessibleNotification(
            title: "Zeit zu üben! 📚",
            body: "Löse ein paar Fragen und verbessere dein Können.",
            accessibilityLabel: "Lernzeit-Benachrichtigung",
            accessibilityHint: "Tippen um zur App zu gehen und Fragen zu bearbeiten"
        ),
        AccessibleNotification(
            title: "Dein Führerschein wartet! 🚗",
            body: "Deine Prüfung rückt näher. Zeit zum Lernen!",
            accessibilityLabel: "Prüfungsvorbereitung-Benachrichtigung",
            accessibilityHint: "Tippen um zu Ihrer Lernseite zu gehen"
        ),
        AccessibleNotification(
            title: "Neugierig auf eine Frage? 🤔",
            body: "Schaffst du die heutige Herausforderung?",
            accessibilityLabel: "Tägliche Herausforderungs-Benachrichtigung",
            accessibilityHint: "Tippen um eine neue Frage zu versuchen"
        )
    ]
    
    static func randomAccessibleNotification() -> AccessibleNotification {
        notifications.randomElement() ?? notifications[0]
    }
}