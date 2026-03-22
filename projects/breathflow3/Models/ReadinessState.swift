// Models/ReadinessState.swift
import SwiftUI

enum ReadinessState: Equatable, Hashable {
    case topicsMastered
    case stillShaky
    case notStarted

    var accentColor: Color {
        switch self {
        case .topicsMastered: return .green
        case .stillShaky: return Color(red: 0.9, green: 0.6, blue: 0)
        case .notStarted: return .gray
        }
    }

    var displayText: String {
        switch self {
        case .topicsMastered: return "Topics Mastered"
        case .stillShaky: return "Still Shaky"
        case .notStarted: return "Not Started"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .topicsMastered: return "Topics mastered - you are ready"
        case .stillShaky: return "Still shaky - more practice needed"
        case .notStarted: return "Not started yet"
        }
    }
}
