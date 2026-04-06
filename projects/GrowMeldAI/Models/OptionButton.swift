// Views/QuestionView.swift – OptionButton Implementation
struct OptionButton: View {
    let index: Int
    let text: String
    let isSelected: Bool
    let isAnswered: Bool
    let isCorrect: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Radio button indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(
                        isSelected
                            ? (isAnswered ? (isCorrect ? AppTheme.palette.correct : AppTheme.palette.incorrect) : AppTheme.palette.primary)
                            : AppTheme.palette.textSecondary
                    )
                    .accessibility(hidden: true) // Redundant with semantic structure
                
                Text(text)
                    .font(.body)
                    .foregroundColor(AppTheme.palette.text)
                    .lineLimit(nil)
                
                Spacer()
            }
            .frame(minHeight: AppTheme.minTouchSize) // Ensure 44×44pt touch target
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected
                            ? AppTheme.palette.primaryLight.opacity(0.3)
                            : AppTheme.palette.neutral
                    )
            )
            .border(
                isSelected ? AppTheme.palette.primary : Color.clear,
                width: 2
            )
        }
        .buttonStyle(.plain)
        .accessibility(label: Text("Option: \(text)"))
        .accessibility(hint: Text(
            isAnswered
                ? (isCorrect ? "Korrekte Antwort" : "Falsche Antwort")
                : "Doppeltippen zum Auswählen"
        ))
        .accessibility(addTraits: .isButton)
        .accessibility(addTraits: isSelected ? .isSelected : [])
        .accessibilityRemoveTraits(.isImage) // Don't treat radio button as image
    }
}