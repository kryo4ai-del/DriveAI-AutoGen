struct LimitApproachBadge: View {
    let level: LimitApproachLevel
    let questionsRemaining: Int?
    
    var body: some View {
        VStack {
            Image(systemName: iconForLevel(level))
                .foregroundColor(level.borderColor)
            
            Text(level.emoji)
                .font(.title)
        }
        .padding()
        .background(level.backgroundColor)
        .border(level.borderColor)
        // ✅ REQUIRED ACCESSIBILITY:
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityElement(children: .ignore)  // Treat as single element
    }
    
    private var accessibilityLabel: String {
        switch level {
        case .safe:
            return "Quota Status: Safe"
        case .warning:
            return "Quota Status: Warning"
        case .critical:
            return "Quota Status: Critical"
        }
    }
    
    private var accessibilityHint: String {
        guard let remaining = questionsRemaining else { return "" }
        return "\(remaining) questions remaining today"
    }
    
    private func iconForLevel(_ level: LimitApproachLevel) -> String {
        switch level {
        case .safe: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.circle.fill"
        }
    }
}