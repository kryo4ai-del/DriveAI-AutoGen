// ViewModels/ExamSimulation/ExamSimulationViewModel.swift
extension ExamSimulationViewModel {
    var resultSummaryForAccessibility: String {
        guard let result = examResult else { return "" }
        
        let statusText = result.passed ? "Bestanden" : "Nicht bestanden"
        let scoreText = "\(result.correctAnswers) von \(result.totalQuestions) richtig"
        let percentageText = String(format: "%.0f%%", result.percentageScore * 100)
        
        var summary = "Prüfungsergebnis: \(statusText). \(scoreText), \(percentageText)."
        
        if !result.categoryBreakdown.isEmpty {
            summary += " Ergebnisse nach Kategorie: "
            let categoryTexts = result.categoryBreakdown.map { category, correct in
                "\(category): \(correct) richtig"
            }
            summary += categoryTexts.joined(separator: ", ")
        }
        
        return summary
    }
    
    var resultDetailedForAccessibility: [String] {
        guard let result = examResult else { return [] }
        
        var details: [String] = []
        details.append("Bestanden: \(result.passed ? "Ja" : "Nein")")
        details.append("Korrekte Antworten: \(result.correctAnswers) von \(result.totalQuestions)")
        details.append("Prozentsatz: \(String(format: "%.1f%%", result.percentageScore * 100))")
        details.append("Benötigte Zeit: \(formatTimeSpent(result.timeSpent))")
        
        return details
    }
    
    private func formatTimeSpent(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return "\(minutes) Minuten, \(secs) Sekunden"
    }
}