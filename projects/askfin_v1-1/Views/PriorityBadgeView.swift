import SwiftUI
extension PriorityLevel {
    var accessibleColor: Color {
        switch self {
        case .high:
            return Color(red: 0.91, green: 0.15, blue: 0.15)
        case .medium:
            return Color(red: 0.95, green: 0.60, blue: 0)
        case .low:
            return Color(red: 0.10, green: 0.55, blue: 0.30)
        }
    }

    var textColor: Color { .white }
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
        .foregroundColor(priority.textColor)
        .background(priority.accessibleColor)
        .cornerRadius(6)
        .accessibilityLabel(Text(priority.description))
    }
}
