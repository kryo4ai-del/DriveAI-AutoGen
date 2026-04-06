// Services/FallbackMessagingService.swift
import Foundation

class FallbackMessagingService {
    
    static func messagingStrategy(
        for stage: ExamStage,
        isInitialFallback: Bool
    ) -> FallbackMessage {
        
        switch stage {
        case .earlyPrep:
            return FallbackMessage(
                primary: "Offline-Modus: Perfekt für fokussiertes Lernen",
                secondary: "Keine Ablenkung, maximale Konzentration",
                tone: .reassuring
            )
            
        case .midStudy:
            return FallbackMessage(
                primary: "Klassische Fragen + deine Statistik",
                secondary: "Alles, was du für die finale Vorbereitung brauchst",
                tone: .motivational
            )
            
        case .finalCramming:
            return FallbackMessage(
                primary: "Prüfungs-ähnliche Fragen sofort verfügbar",
                secondary: isInitialFallback ? "Du bist bereit" : nil,
                tone: .reassuring
            )
        }
    }
    
    static func toastMessage(for stage: ExamStage) -> String {
        "Offline-Modus aktiviert — Fragen funktionieren normal"
    }
}