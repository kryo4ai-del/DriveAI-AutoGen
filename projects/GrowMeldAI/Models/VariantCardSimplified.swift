// SIMPLIFIED VIEW (default)
struct VariantCardSimplified: View {
    let variant: ABVariant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(variant.name)  // "Detailed Explanations"
                    .font(.headline)
                Spacer()
                if let impact = variant.impact {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                        Text(impact)  // "Users learn 12% faster"
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.green)
                }
            }
            
            Text(variant.description)  // Plain English description
                .font(.body)
                .lineLimit(2)
            
            // Disclosure button for technical details
            Button(action: { showDetails = true }) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("See technical details")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
        }
        .sheet(isPresented: $showDetails) {
            VariantDetailsSheet(variant: variant)  // Raw metadata here
        }
    }
}