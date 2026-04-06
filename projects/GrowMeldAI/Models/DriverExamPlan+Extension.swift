import Foundation

extension DriverExamPlan {
    var accessibilityAnnouncement: String {
        let readinessPercent = Int(readinessScore * 100)
        let totalQuestions = recommendedQuestions.count

        let highUrgency = recommendedQuestions.filter { $0.urgency == .high }.count
        let mediumUrgency = recommendedQuestions.filter { $0.urgency == .medium }.count
        let lowUrgency = recommendedQuestions.filter { $0.urgency == .low }.count

        var announcement = "Plan aktualisiert. "
        announcement += "Deine Bereitschaft: \(readinessPercent)%. "
        announcement += "\(totalQuestions) Fragen insgesamt. "
        announcement += "\(highUrgency) Fragen mit hoher Priorität, "
        announcement += "\(mediumUrgency) mit mittlerer, "
        announcement += "\(lowUrgency) mit niedriger Priorität."

        if daysUntilExam <= 7 {
            announcement += " Prüfung in \(daysUntilExam) Tag\(daysUntilExam == 1 ? "" : "en")."
        }

        return announcement
    }
}