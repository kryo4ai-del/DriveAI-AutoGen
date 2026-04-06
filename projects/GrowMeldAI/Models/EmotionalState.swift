// File: Models/EmotionalState.swift
import Foundation

/// Represents the user's emotional state during learning sessions
/// Used to provide motivational feedback and track progress toward exam readiness
enum EmotionalState: String, Codable, CaseIterable {
    case anxious
    case calm
    case gainingConfidence
    case confident
    case examReady
    case frustrated

    var description: String {
        switch self {
        case .anxious: return "Prüfungsangst"
        case .calm: return "Entspannt"
        case .gainingConfidence: return "Sicherer werdend"
        case .confident: return "Selbstbewusst"
        case .examReady: return "Prüfungsbereit"
        case .frustrated: return "Frustriert"
        }
    }

    var motivationalMessage: String {
        switch self {
        case .anxious: return "Du schaffst das! Jede Frage bringt dich näher ans Ziel."
        case .calm: return "Gut so! Bleib dran und du wirst immer sicherer."
        case .gainingConfidence: return "Super! Du machst große Fortschritte."
        case .confident: return "Fantastisch! Du bist fast bereit für die Prüfung."
        case .examReady: return "Perfekt! Du bist bereit für die echte Prüfung."
        case .frustrated: return "Keine Sorge - jeder macht Fehler. Lern daraus und mach weiter!"
        }
    }
}