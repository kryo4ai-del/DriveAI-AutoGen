struct FeatureCardView: View {
    let feature: PurchasableFeature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: feature.icon ?? "star.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                Text(feature.name)
                    .font(.headline)
                    .lineLimit(nil)  // ✅ Support Dynamic Type
                
                Spacer()
            }
            
            Text(feature.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(nil)  // ✅ Wrap to multiple lines
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Text("€\(feature.price, specifier: "%.2f")")
                    .font(.headline)
                    .accessibilityValue("\(feature.price) Euro")
                
                Spacer()
                
                Button("Kaufen") { }
                    .frame(height: 44)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}