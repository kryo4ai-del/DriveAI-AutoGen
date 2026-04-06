struct OverallProgress: Identifiable {
    // ... existing fields
    
    var accessibilityStreakHint: String {
        let streakText: String
        switch currentStreak {
        case 0:
            streakText = String(localized: "no_current_streak")
        case 1:
            streakText = String(localized: "one_day_streak")
        default:
            streakText = String(localized: "n_day_streak", 
                               arguments: [currentStreak])
        }
        return "\(streakText). Beantworte Fragen jeden Tag, um eine Strähne zu erhalten."
    }
}

// In StreakIndicatorView:
VStack {
    Image(systemName: "flame.fill")
        .font(.system(size: 24))
    Text("\(progress.currentStreak)")
        .font(.headline)
    Text("Tage")
        .font(.caption)
}
.accessibilityLabel("Aktuelle Strähne")
.accessibilityHint(progress.accessibilityStreakHint)
.accessibilityValue(String(progress.currentStreak))