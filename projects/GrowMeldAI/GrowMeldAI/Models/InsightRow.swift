struct InsightRow: View {
    let insight: MemoryInsight
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(insight.category)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text(insight.narrative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(insight.confidencePercentage * 100))%")
                            .font(.headline)
                            .foregroundStyle(confidenceColor(insight.confidencePercentage))
                        
                        Text(insight.trend.emoji)
                            .font(.caption)
                    }
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                        .accessibilityHidden(true)  // Icon is decorative; state is announced elsewhere
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(insight.category)
            .accessibilityValue("\(Int(insight.confidencePercentage * 100))%")
            .accessibilityHint(insight.narrative)
            .accessibilityAddTraits(.isButton)
            .accessibilityCustomAction(
                name: isExpanded ? "Einklappen" : "Ausklappen",
                handler: { _ in
                    onTap()
                    return true
                }
            )
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .accessibilityHidden(true)
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Überprüft")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .accessibilityAddTraits(.isHeader)
                            
                            Text("\(insight.reviewedCount)")
                                .font(.headline)
                                .accessibilityLabel("Überprüfte Fragen")
                                .accessibilityValue("\(insight.reviewedCount)")
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gesamt")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .accessibilityAddTraits(.isHeader)
                            
                            Text("\(insight.totalCount)")
                                .font(.headline)
                                .accessibilityLabel("Gesamtfragen")
                                .accessibilityValue("\(insight.totalCount)")
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Label(insight.nextActionLabel, systemImage: insight.nextActionIcon)
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(6)
                                .background(Color.blue)
                                .cornerRadius(6)
                        }
                        .accessibilityLabel(insight.nextActionLabel)
                        .accessibilityHint("Starten Sie eine Quizrunde für \(insight.category)")
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .accessibilityElement(children: .contain)
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.75 { return .green }
        if confidence >= 0.5 { return .orange }
        return .red
    }
}