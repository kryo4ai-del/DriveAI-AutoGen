struct CategoryScoreRow: View {
    let category: String
    let score: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(Int(score))%")
                    .font(.subheadline.bold())
                    .foregroundColor(score >= 80 ? .green : score >= 70 ? .yellow : .red)
            }
            
            ProgressView(value: score / 100)
                .tint(scoreColor(score))
        }
        .padding(.vertical, 12)  // ✅ Minimum 44pt total height
        .padding(.horizontal)
        .frame(minHeight: 44)  // ✅ Explicit minimum touch target
        .contentShape(Rectangle())  // ✅ Entire area is tappable
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category) category")
        .accessibilityValue("\(Int(score)) percent correct")
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 80 { return .green }
        if score >= 70 { return .yellow }
        return .red
    }
}