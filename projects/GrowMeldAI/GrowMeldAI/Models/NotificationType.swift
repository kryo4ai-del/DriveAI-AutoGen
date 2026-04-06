enum NotificationType: String, CaseIterable, Codable, Hashable {
    case examReadinessCheckpoint = "exam_readiness"
    case weakAreaAlert = "weak_area"
    case streakMilestone = "streak_milestone"
    case examDateReminder = "exam_date"
    case dailyMotivation = "daily_motivation"
    
    // MARK: - Accessibility Variants
    
    /// Full, descriptive title for VoiceOver & accessibility contexts
    var accessibleTitle: String {
        switch self {
        case .examReadinessCheckpoint:
            return "Lernfortschritt: Du schaffst das! Wähle eine Frage zum Trainieren"
        case .weakAreaAlert:
            return "Schwachstellen gefunden. Trainiere deine schwächsten Themen"
        case .streakMilestone:
            return "Glückwunsch! Du hast eine Trainings-Serie erreicht"
        case .examDateReminder:
            return "Erinnerung: Dein Prüfungstag rückt näher. Heute üben?"
        case .dailyMotivation:
            return "Tägliches Training: 10 Minuten Übung heute können dir helfen"
        }
    }
    
    /// Visual title with emoji (for sighted users)
    var displayTitle: String {
        switch self {
        case .examReadinessCheckpoint:
            return "Du bist 1 Schritt näher! 🎯"
        case .weakAreaAlert:
            return "Zeit für Schwachstellen 📚"
        case .streakMilestone:
            return "Glückwunsch zur Serie! 🔥"
        case .examDateReminder:
            return "Dein Prüfungstag rückt näher"
        case .dailyMotivation:
            return "Heute eine Runde üben? 💪"
        }
    }
}

// MARK: - When dispatching notifications:
// Build payload with accessibility in mind