// ToxicityWarningModel.swift
import Foundation

/// Represents the severity level of a toxicity warning
enum ToxicityLevel: String, Codable, CaseIterable {
    case info
    case warning
    case critical

    var localizedString: String {
        switch self {
        case .info: return "Info"
        case .warning: return "Achtung"
        case .critical: return "WICHTIG"
        }
    }

    var systemImage: String {
        switch self {
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .critical: return "exclamationmark.shield"
        }
    }
}

/// Represents a specific group affected by toxicity
enum AffectedGroup: String, Codable, CaseIterable {
    case children
    case pets
    case elderly
    case pregnant
    case disabled

    var localizedString: String {
        switch self {
        case .children: return "Kinder"
        case .pets: return "Haustiere"
        case .elderly: return "Senioren"
        case .pregnant: return "Schwangere"
        case .disabled: return "Menschen mit Behinderungen"
        }
    }
}

/// Contains localized content for a toxicity warning
struct WarningContent: Codable {
    let localizedTitle: String
    let localizedDescription: String
    let safetyTips: [String]
}

/// Links a toxicity warning to specific theory questions
struct TheoryQuestionLink: Codable, Identifiable {
    let id: String
    let questionIds: [String]
}

/// Complete toxicity warning data model
struct ToxicityWarning: Identifiable, Codable {
    let id: String
    let level: ToxicityLevel
    let affectedGroups: [AffectedGroup]
    let content: WarningContent
    let questionLinks: [TheoryQuestionLink]
    let isActive: Bool
}