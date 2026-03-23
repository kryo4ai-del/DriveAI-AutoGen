import SwiftUI

extension AnxietyLevel {
    var color: Color {
        switch self {
        case .low:    return Color(.systemGreen)
        case .medium: return Color(.systemOrange)
        case .high:   return Color(.systemRed)
        }
    }
}