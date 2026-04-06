struct CategoryCardView: View {
    let category: Category
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(category.icon)
                    .font(.system(size: 40))
                Text(category.name)
                    .font(.body)  // Larger, readable
                Text("\(category.questionCount) Fragen")
                    .font(.caption)
            }
            .frame(minHeight: 100)  // Ensure 44pt minimum in both dimensions
            .frame(maxWidth: .infinity)
            .padding(12)
            .contentShape(Rectangle())  // Expand tap target
        }
        .accessibilityLabel("Kategorie: \(category.name)")
        .accessibilityHint("\(category.questionCount) Fragen. Doppeltippen zum Öffnen.")
    }
}