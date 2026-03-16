import SwiftUI

enum PriorityLevel: String, Codable, Sendable {
    case high
    case medium
    case low

    var icon: String {
        switch self {
        case .high: return "exclamationmark.triangle.fill"
        case .medium: return "arrow.up.circle.fill"
        case .low: return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }

    var description: String {
        switch self {
        case .high: return "Hohe Priorität"
        case .medium: return "Mittlere Priorität"
        case .low: return "Niedrige Priorität"
        }
    }
}
