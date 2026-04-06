struct InsightsListSection: View {
    let insights: [MemoryInsight]
    @State private var expandedCategory: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kategorien")
                .font(.headline)
            
            if insights.isEmpty {
                Text("Noch keine Daten. Starten Sie eine Quizrunde!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(spacing: 8) {
                    ForEach(insights) { insight in
                        InsightRow(
                            insight: insight,
                            isExpanded: expandedCategory == insight.category,
                            onTap: {
                                withAnimation {
                                    expandedCategory = expandedCategory == insight.category
                                        ? nil
                                        : insight.category
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
