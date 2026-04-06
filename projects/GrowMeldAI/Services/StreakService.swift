class StreakService {
    /// Calculate exam readiness based on streak + current mastery
    func estimateExamReadiness(
        streakDays: Int,
        currentMasteryPercent: Int,
        questionsPerDay: Int,
        daysUntilExam: Int
    ) -> ExamReadinessPrediction {
        
        let projectedQuestionsReviewed = questionsPerDay * streakDays
        let projectedFinalMastery = min(100, currentMasteryPercent + (streakDays * 3))
        let estimatedPassProbability = calculatePassProbability(
            mastery: projectedFinalMastery,
            daysRemaining: daysUntilExam
        )
        
        return ExamReadinessPrediction(
            estimatedFinalMastery: projectedFinalMastery,
            passPercentage: estimatedPassProbability,
            streakMotivationMessage: motivationMessage(
                streakDays: streakDays,
                daysUntilExam: daysUntilExam,
                passChance: estimatedPassProbability
            )
        )
    }
    
    private func motivationMessage(streakDays: Int, daysUntilExam: Int, passChance: Int) -> String {
        if passChance >= 85 {
            return "Deine \(streakDays)-Tage-Strähne bringt dich zu 85% Bestehenswahrscheinlichkeit. \(daysUntilExam) Tage bis zur Prüfung — halte durch!"
        } else if passChance >= 70 {
            return "Du bist auf dem richtigen Weg. \(streakDays) Tage gelernt, noch \(daysUntilExam) Tage Zeit. Fokus auf schwierige Fragen."
        } else {
            return "Deine Strähne ist wichtig. \(daysUntilExam) Tage zum Lernen — tägliche Wiederholung ist jetzt kritisch."
        }
    }
}