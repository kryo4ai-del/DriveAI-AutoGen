enum MotivationService {
    static func generateMessage(
        for readiness: ExamReadiness,
        userStreak: Int
    ) -> String {
        let daysLeft = readiness.userProfile.daysUntilExam
        let tier = MotivationalTier.tier(for: daysLeft)
        let primaryCategory = readiness.primaryWeakCategory?.categoryName ?? "allgemein"
        
        // Tier-based escalation
        switch (tier, readiness.status) {
        // Final week (0-7 days)
        case (.finalWeek, .ready):
            return "🏆 Nur noch \(daysLeft) Tag\(daysLeft == 1 ? "" : "e")! Du bist sehr gut vorbereitet!"
        
        case (.finalWeek, .inProgress):
            return "⚡ \(daysLeft) Tage — fokussiere dich auf \(primaryCategory). Dein Streak: \(userStreak) 🔥"
        
        case (.finalWeek, .needsReview):
            return "🎯 INTENSIVE PHASE: Übe täglich \(readiness.recommendedDailyMinutes) Min bei \(primaryCategory)!"
        
        // Two weeks (8-14 days)
        case (.twoWeeks, .ready):
            return "✅ Noch zwei Wochen! Du machst gute Fortschritte."
        
        case (.twoWeeks, .inProgress):
            return "📚 Zwei Wochen Zeit — fokussiere auf \(primaryCategory) für +\(readiness.readinessPercentage)%."
        
        case (.twoWeeks, .needsReview):
            return "⚠️ Zwei Wochen noch! Starte intensive Übungen bei \(primaryCategory)."
        
        // Month+ (15+ days)
        case (.monthPlus, _):
            return "📅 Du hast genug Zeit! Starte mit \(primaryCategory) und baue dein Wissen auf."
        
        // Unknown date
        case (.unknownDate, _):
            return "🚀 Kein Prüfungsdatum gesetzt. Beginne mit den Grundlagen!"
        }
    }
}