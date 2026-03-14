import Foundation

extension LearningStreak {

    /// Human-readable streak label for the UI.
    var streakLabel: String {
        switch currentStreak {
        case 0:
            return "Noch kein Streak"
        case 1:
            return "1 Tag am Stück"
        case 2...6:
            return "\(currentStreak) Tage am Stück"
        case 7...13:
            return "\(currentStreak) Tage am Stück 🔥"
        default:
            return "\(currentStreak) Tage am Stück 🔥🔥"
        }
    }

    /// Motivational message shown after a session completes.
    var motivationMessage: String {
        switch currentStreak {
        case 0:
            return "Starte heute deine Lernserie!"
        case 1:
            return "Guter Start! Morgen weitermachen."
        case 2...6:
            return "Stark! Bleib dran."
        case 7...13:
            return "Eine ganze Woche! Weiter so!"
        case 14...29:
            return "Zwei Wochen durchgehalten — beeindruckend!"
        default:
            return "Unglaublich! \(currentStreak) Tage ohne Pause!"
        }
    }

    /// SF Symbol name matching the streak state.
    var streakIcon: String {
        switch currentStreak {
        case 0:
            return "flame"
        case 1...6:
            return "flame.fill"
        default:
            return "flame.fill"
        }
    }

    /// Color name for the streak indicator (maps to asset catalog or system color).
    var streakColorName: String {
        switch currentStreak {
        case 0:
            return "gray"
        case 1...6:
            return "orange"
        default:
            return "red"
        }
    }
}
