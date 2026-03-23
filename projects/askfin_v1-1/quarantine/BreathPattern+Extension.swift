import SwiftUI

extension BreathPattern {

    var accentColor: Color {
        switch id {
        case "box":      return Color(.systemBlue)
        case "calm":     return Color(.systemPurple)
        case "energize": return Color(.systemOrange)
        default:         return Color(.systemBlue)
        }
    }

    var patternIcon: String {
        switch id {
        case "box":      return "square.fill"
        case "calm":     return "moon.fill"
        case "energize": return "bolt.fill"
        default:         return "wind"
        }
    }

    var estimatedDurationLabel: String {
        let total = Int(totalDuration)
        let minutes = total / 60
        let seconds = total % 60
        if minutes == 0 { return "ca. \(seconds) Sek." }
        if seconds == 0 { return "ca. \(minutes) Min." }
        return "ca. \(minutes) Min. \(seconds) Sek."
    }

    var phaseBreakdownLabel: String {
        phases.map { String(Int($0.duration)) }.joined(separator: "-")
    }
}