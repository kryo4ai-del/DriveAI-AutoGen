struct CategoryStrengthCard: View {
    let category: CategoryReadiness
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Left side: Category info
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(category.percentage)% · \(category.correctAnswers)/\(category.totalQuestions)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Right side: Strength badge + action button
                VStack(alignment: .trailing, spacing: 8) {
                    Text(category.strength.label)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(strengthColor(category.strength))
                        .cornerRadius(4)
                    
                    // ✅ Explicit button for accessibility
                    NavigationLink(destination: FocusedStudyView(categoryId: category.id)) {
                        Image(systemName: "arrow.right")
                            .frame(width: 44, height: 44) // Minimum iOS touch target
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Training für \(category.name) starten")
                    .accessibilityHint("Öffnet fokussierte Übungssession für diesen Bereich")
                }
            }
            
            // Progress bar
            ProgressView(value: Double(category.percentage) / 100)
                .tint(strengthColor(category.strength))
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .frame(minHeight: 80) // ✅ Ensure adequate height
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category.name): \(category.percentage)%")
        .accessibilityValue(category.strength.label)
        .accessibilityHint("Doppeltippen zum Trainieren")
    }
    
    private func strengthColor(_ strength: StrengthRating) -> Color {
        switch strength {
        case .weak: return Color.red.opacity(0.2)
        case .moderate: return Color.yellow.opacity(0.2)
        case .strong: return Color.green.opacity(0.2)
        case .excellent: return Color.blue.opacity(0.2)
        }
    }
}