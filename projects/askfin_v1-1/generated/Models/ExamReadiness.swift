import Foundation

struct ExamReadiness {
    let passedSimulations: Int
    let averageScore: Double
    let streakDays: Int
    let categoryWeaknesses: [String] // categories < 80%
    
    var readinessPercentage: Double {
        // Weighted: pass rate (50%), average (30%), streak (20%)
        let passContribution = min(Double(passedSimulations) / 5.0, 1.0) * 0.5
        let scoreContribution = averageScore * 0.3
        let streakContribution = min(Double(streakDays) / 30.0, 1.0) * 0.2
        return passContribution + scoreContribution + streakContribution
    }
    
    var recommendation: String {
        if readinessPercentage >= 0.85 { return "Du bist bereit für die echte Prüfung!" }
        if readinessPercentage >= 0.70 { return "Fast bereit — übe noch die schwächeren Kategorien." }
        return "Weiter trainieren — du schaffst das!"
    }
}