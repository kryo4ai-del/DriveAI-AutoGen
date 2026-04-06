class MotivationalMessagingService {
    func generateMessage(
        status: ExaminationStatus,
        progressPercent: Double,
        daysUntilExam: Int,
        streak: Int,
        weakCategories: [QuestionCategory]
    ) -> String {
        // Phase-specific messaging (4 scenarios):
        
        switch status {
        case .preparing:
            // >14 days: "You've got this! Build momentum."
            return "📚 Noch \(daysUntilExam) Tage — jetzt die Basis festigen!"
            
        case .urgent:
            // 3–14 days: "Final push needed. Intensity matters."
            return "⚡ Nur noch \(daysUntilExam) Tage — \(weakCategories.first?.rawValue ?? "kritische") Bereiche trainieren!"
            
        case .ready:
            // 1–2 days: "Confidence building. Review, don't learn new."
            return "🎯 Morgen ist der Tag — Wiederholung und Ruhe!"
            
        case .completed:
            return "🏆 Prüfung geschafft! Dein nächstes Ziel: Weitere Kategorien meistern."
        }
    }
    
    func getMotivationalElement(streak: Int) -> MotivationalElement {
        if streak > 7 { return .streakCelebration }
        if streak >= 3 { return .customizedFeedback }
        return .goalGradient
    }
}

Services/WeakCategoryAnalyzerService.swift
├── WeakCategoryAnalyzerService (class)
│   ├── func identifyWeakCategories(
│   │       progress: UserProgress,
│   │       threshold: Double = 0.30
│   │   ) -> [QuestionCategory]
│   │   └── Returns categories where errorRate > threshold
│   │
│   └── func prioritizeForReview(
│           weakCategories: [QuestionCategory],
│           daysUntilExam: Int
│       ) -> QuestionCategory
│       └── Returns single highest-impact category to focus on