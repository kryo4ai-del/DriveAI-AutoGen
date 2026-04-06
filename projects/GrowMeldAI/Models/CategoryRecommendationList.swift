struct CategoryRecommendationList: View {
    let categories: [CategoryStats]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kategorien zum Üben")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            ForEach(categories, id: \.id) { category in
                CategoryActionButton(category: category)
                    .frame(minHeight: 56)  // ✓ Touch target 44pt minimum
            }
        }
        .padding()
        .accessibilityElement(children: .contain)
    }
}

struct CategoryActionButton: View {
    let category: CategoryStats
    @Environment(\.isEnabled) var isEnabled
    
    var body: some View {
        Button(action: {
            // Navigate to category practice
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.categoryName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 16) {
                        Label("\(category.questionsAnswered) Fragen", systemImage: "questionmark.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(Int(category.accuracyRate * 100))%", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(accuracyColor)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(minHeight: 56)  // ✓ 44pt minimum
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .accessibilityLabel("Übe \(category.categoryName)")
        .accessibilityValue("\(category.questionsAnswered) Fragen, \(Int(category.accuracyRate * 100))% korrekt")
        .accessibilityHint("Doppeltippen, um zu starten")
    }
    
    private var accuracyColor: Color {
        switch category.accuracyRate {
        case 0.8...: return .green
        case 0.6..<0.8: return .yellow
        default: return .red
        }
    }
}