// DriveAI/Features/TrialMechanik/Presentation/MotivationalStrategy.swift
import Foundation

struct MotivationalStrategy {
    func feedback(
        daysPercent: Double,
        questionsPercent: Double,
        daysRemaining: Int
    ) -> MotivationalMessage {
        // Urgency based on days remaining
        let urgency: MotivationalMessage.Urgency
        if daysRemaining <= 1 {
            urgency = .high
        } else if daysRemaining <= 3 {
            urgency = .medium
        } else {
            urgency = .low
        }

        // Motivational messages based on progress
        if daysPercent < 0.2 && questionsPercent < 0.3 {
            return MotivationalMessage(
                title: "Starte jetzt mit dem Lernen!",
                subtitle: "Jede Frage bringt dich näher ans Ziel",
                urgency: urgency
            )
        } else if questionsPercent >= 0.8 {
            return MotivationalMessage(
                title: "Super! Du bist auf Kurs",
                subtitle: "\(daysRemaining) Tage bis zur Prüfung",
                urgency: .low
            )
        } else if daysPercent < 0.5 {
            return MotivationalMessage(
                title: "Fast die Hälfte geschafft!",
                subtitle: "Weiter so, du bist auf einem guten Weg",
                urgency: urgency
            )
        } else {
            return MotivationalMessage(
                title: "Du schaffst das!",
                subtitle: "Jede richtige Antwort zählt",
                urgency: urgency
            )
        }
    }
}