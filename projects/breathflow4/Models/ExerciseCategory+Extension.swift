import SwiftUI

extension ExerciseCategory {
    var color: Color {
        switch self {
        case .calm: return Color(red: 0.4, green: 0.8, blue: 0.6)
        case .focus: return Color(red: 0.3, green: 0.6, blue: 0.9)
        case .energy: return Color(red: 1.0, green: 0.7, blue: 0.2)
        case .sleep: return Color(red: 0.5, green: 0.3, blue: 0.8)
        case .stress: return Color(red: 0.9, green: 0.4, blue: 0.4)
        }
    }
    
    var backgroundGradient: LinearGradient {
        let startColor = color.opacity(0.3)
        let endColor = color.opacity(0.05)
        return LinearGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}