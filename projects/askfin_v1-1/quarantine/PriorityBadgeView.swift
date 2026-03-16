import SwiftUI
extension PriorityLevel {
    // ✅ Updated color palette with proper contrast
    var accessibleColor: Color {
        switch self {
        case .critical:
            return Color(red: 0.91, green: 0.15, blue: 0.15) // Darker red (#E80808)
        case .needsWork:
            return Color(red: 0.95, green: 0.60, blue: 0) // Darker orange (#F29700)
        case .good:
            return Color(red: 0.70, green: 0.55, blue: 0) // Darker golden (#B38B00)
        case .mastered:
            return Color(red: 0.10, green: 0.55, blue: 0.30) // Darker green (#1A8C4D)
        }
    }
    
    /// Text color for contrast against priority colors
    var textColor: Color {
        switch self {
        case .critical, .needsWork, .good:
            return .white
        case .mastered:
            return .white
        }
    }
}

struct PriorityBadgeView: View {
    let priority: PriorityLevel
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: priority.icon)
                .font(.caption2)
            
            Text(priority.description)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        // ✅ Use accessible colors with sufficient contrast
        .foregroundColor(priority.textColor)
        .background(priority.accessibleColor)
        .cornerRadius(6)
        .accessibilityLabel(Text(priority.description))
    }
}