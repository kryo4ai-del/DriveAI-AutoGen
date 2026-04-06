// ✅ AFTER:
struct FocusLevelBadge: View {
    let level: FocusLevel
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(level.color)
                .frame(width: 10, height: 10)
                .accessibilityHidden(true)
            
            Text(level.displayName)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(level.color)
        .cornerRadius(4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Priorität: \(level.displayName)")
        .accessibilityValue(level.description)
    }
}

extension FocusLevel {
    var color: Color {
        switch self {
        case .critical: return .focusCritical
        case .important: return .focusImportant
        case .monitor: return .focusMonitor
        }
    }
    
    var description: String {
        switch self {
        case .critical: return "Sofort üben erforderlich"
        case .important: return "Wichtig zu wiederholen"
        case .monitor: return "Im Auge behalten"
        }
    }
}