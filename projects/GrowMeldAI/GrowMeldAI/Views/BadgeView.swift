import SwiftUI

struct BadgeView: View {
    enum BadgeType: Equatable {
        case streak(days: Int)
        case milestone(name: String)
        case achievement(title: String)
        
        var icon: String {
            switch self {
            case .streak: return "flame.fill"
            case .milestone: return "star.fill"
            case .achievement: return "checkmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .streak: return .orange
            case .milestone: return .yellow
            case .achievement: return .green
            }
        }
    }
    
    let type: BadgeType
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: type.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(isUnlocked ? type.color : Color(.systemGray3))
                .clipShape(Circle())
                .shadow(
                    color: isUnlocked ? type.color.opacity(0.3) : .clear,
                    radius: 4,
                    x: 0,
                    y: 2
                )
            
            BadgeLabel(type: type)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .lineLimit(1)
        }
        .opacity(isUnlocked ? 1 : 0.6)
        .accessibilityLabel(badgeAccessibilityLabel)
    }
    
    private var badgeAccessibilityLabel: String {
        let status = isUnlocked ? "Freigeschaltet" : "Gesperrt"
        switch type {
        case .streak(let days):
            return "\(days)-Tage-Serie: \(status)"
        case .milestone(let name):
            return "\(name) Meilenstein: \(status)"
        case .achievement(let title):
            return "\(title): \(status)"
        }
    }
    
    @ViewBuilder
    private func BadgeLabel(type: BadgeType) -> some View {
        switch type {
        case .streak(let days):
            Text("\(days) Tage")
        case .milestone(let name):
            Text(name)
        case .achievement(let title):
            Text(title)
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        BadgeView(type: .streak(days: 5), isUnlocked: true)
        BadgeView(type: .milestone(name: "10er"), isUnlocked: true)
        BadgeView(type: .achievement(title: "100%"), isUnlocked: false)
    }
    .padding()
}