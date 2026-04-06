// Models/EmotionalTag.swift
import Foundation

enum EmotionalTag: String, Codable, CaseIterable {
    case proud = "proud"
    case confident = "confident"
    case relieved = "relieved"
    case frustrated = "frustrated"
    case determined = "determined"
    case surprised = "surprised"
    case grateful = "grateful"
    case motivated = "motivated"
    
    var displayName: String {
        switch self {
        case .proud: return "Stolz"
        case .confident: return "Selbstbewusst"
        case .relieved: return "Erleichtert"
        case .frustrated: return "Frustriert"
        case .determined: return "Entschlossen"
        case .surprised: return "Überrascht"
        case .grateful: return "Dankbar"
        case .motivated: return "Motiviert"
        }
    }
    
    var emoji: String {
        switch self {
        case .proud: return "😌"
        case .confident: return "💪"
        case .relieved: return "😅"
        case .frustrated: return "😤"
        case .determined: return "🎯"
        case .surprised: return "😲"
        case .grateful: return "🙏"
        case .motivated: return "🚀"
        }
    }
}