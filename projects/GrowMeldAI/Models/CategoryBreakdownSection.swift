struct CategoryBreakdownSection: View {
    let categoryResults: [CategoryBreakdown]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            if categoryResults.isEmpty {
                Text("No category data available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Text("Performance by Category")
                    .font(.headline)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)
                
                ForEach(categoryResults.indices, id: \.self) { index in
                    if let breakdown = categoryResults[safe: index] {
                        CategoryResultRow(breakdown: breakdown)
                    }
                }
            }
        }
    }
}

// Add safety extension:
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}