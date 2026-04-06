struct DetailedReadiness {
    let totalQuestionsCatalog: Int           // e.g., 1200
    let questionsAnswered: Int               // e.g., 450
    let questionsAtMastery: Int              // ≥0.9 retrieval strength
    let questionsDueSoon: Int                // Urgency .dangerous or .attention
    
    var readinessMessage: String {
        let percentAnswered = Double(questionsAnswered) / Double(totalQuestionsCatalog) * 100
        let percentMastered = Double(questionsAtMastery) / Double(questionsAnswered) * 100
        
        if percentAnswered < 20 {
            return "Du hast \(questionsAnswered) von \(totalQuestionsCatalog) Fragen beantwortet. Ziel: 600+ für Sicherheit."
        }
        if percentMastered < 75 {
            return "Gut! \(percentAnswered.rounded())% angesehen, aber nur \(Int(percentMastered))% meistert. Fokus: Schwache Kategorien."
        }
        if questionsDueSoon > 0 {
            return "Fast bereit! \(questionsDueSoon) Fragen brauchen diese Woche Auffrischung."
        }
        return "Du bist bereit! Nimm morgen eine Prüfung."
    }
}