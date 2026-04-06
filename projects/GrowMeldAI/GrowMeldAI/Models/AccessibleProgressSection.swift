struct AccessibleProgressSection: View {
    let reviewedCount: Int
    let totalCount: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: Double(reviewedCount), total: Double(totalCount))
                .accessibilityLabel("Überprüfungsfortschritt")
                .accessibilityValue("\(percentage)% abgeschlossen")
            
            Text("\(percentage)% abgeschlossen")
                .scaledFont(.caption)  // ✅ Dynamic Type support
                .accessibilityHidden(true)  // Avoid duplication with ProgressView
        }
        .accessibilityElement(children: .contain)
    }
}