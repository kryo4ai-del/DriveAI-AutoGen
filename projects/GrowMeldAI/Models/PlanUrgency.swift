import SwiftUI
enum PlanUrgency: String, Codable, CaseIterable, Hashable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var color: Color {
        switch self {
        case .high: return Color(red: 1.0, green: 0.231, blue: 0.188)      // #FF3B30
        case .medium: return Color(red: 1.0, green: 0.584, blue: 0.0)      // #FF9500
        case .low: return Color(red: 0.204, green: 0.784, blue: 0.349)     // #34C759
        }
    }
}