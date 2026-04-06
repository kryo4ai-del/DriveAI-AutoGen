// MARK: - Presentation/Common/Components/ActionButton.swift

struct AccessibleActionButton: View {
    let label: String
    let icon: String
    let isHighlighted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                Text(label)
                    .font(.body)
                Spacer()
            }
            .padding(.vertical, 16)  // Vertical: 44pt minimum (16 + padding)
            .padding(.horizontal, 16)
            .frame(minHeight: 44)  // ← EXPLICIT minimum touch target
            .background(isHighlighted ? Color.blue : Color(.systemBackground))
            .foregroundColor(isHighlighted ? .white : .primary)
            .cornerRadius(8)
            .contentShape(Rectangle())  // ← Ensure entire frame is tappable
        }
        .accessibilityLabel(label)
        .accessibilityHint("Doppeltippen zum Aktivieren")
        .accessibilityAddTraits(.isButton)
    }
}