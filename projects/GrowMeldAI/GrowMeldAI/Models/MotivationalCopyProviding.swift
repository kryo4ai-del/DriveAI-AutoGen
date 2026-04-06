// Services/MotivationalCopyProvider.swift
import Foundation

protocol MotivationalCopyProviding {
    func text(
        for tier: ExamReadinessTier,
        in zone: TemporalZone,
        daysUntilExam: Int,
        overallScore: Int,
        now: Date
    ) -> String
}

@MainActor
final class MotivationalCopyProvider: MotivationalCopyProviding {
    private let calendar = Calendar.current
    
    func text(
        for tier: ExamReadinessTier,
        in zone: TemporalZone,
        daysUntilExam: Int,
        overallScore: Int,
        now: Date = Date()
    ) -> String {
        let tierText = tierSpecificText(tier, overallScore: overallScore, daysUntilExam: daysUntilExam)
        let zoneText = zoneSpecificText(zone, daysUntilExam: daysUntilExam)
        let timeText = timeContextText(now: now)
        
        return "\(tierText) \(zoneText) \(timeText)"
    }
    
    // MARK: - Private Helpers
    
    private func tierSpecificText(_ tier: ExamReadinessTier, overallScore: Int, daysUntilExam: Int) -> String {
        switch tier {
        case .needsWork(let questionsRemaining):
            let pointsNeeded = max(0, 68 - overallScore)
            return "Du bist auf \(overallScore)%. Noch \(pointsNeeded) Punkte bis zur Prüfungs-Sicherheit."
        
        case .makingProgress(let confidence):
            let verb = confidence == "wachsen" ? "wächst täglich" : "ist sehr stark"
            return "Großartig! Dein Vertrauen \(verb)."
        
        case .almostReady:
            return "Du bist fast bereit! In \(daysUntilExam) Tagen Prüfung—kleine Auffrischungen, großes Vertrauen."
        
        case .ready:
            return "🎯 Prüfungsreif. Vertrau deinem Lernen—du hast dich gut vorbereitet."
        }
    }
    
    private func zoneSpecificText(_ zone: TemporalZone, daysUntilExam: Int) -> String {
        switch zone {
        case .earlyStage:
            return "Mastery-Mindset: Eine Kategorie pro Woche aufbauen."
        case .buildingPhase:
            return "Geht los: Schwache Punkte jetzt beheben."
        case .finalPush:
            return "Endspurt: Fokus auf Wiederholung in den letzten \(daysUntilExam) Tagen."
        case .lastMinute:
            return "Vertraue deiner Prep—Panik hilft nicht."
        }
    }
    
    private func timeContextText(now: Date) -> String {
        let hour = calendar.component(.hour, from: now)
        
        switch hour {
        case 6..<10: return "Morgenfrische nutzen!"
        case 10..<14: return "Zwischen den Aktivitäten—eine schnelle Frage?"
        case 14..<18: return "Nachmittagsfrische: Neue Kategorie?"
        case 18..<22: return "Heute nochmal 15 Min Wiederholung?"
        default: return "Gut gemacht—morgen geht's weiter."
        }
    }
}