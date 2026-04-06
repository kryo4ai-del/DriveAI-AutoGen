struct TrialExpiringView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    let daysRemaining: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Adaptive countdown size based on Dynamic Type
            let baseFontSize: CGFloat = dynamicTypeSize > .xxLarge ? 36 : 48
            
            Text("\(daysRemaining)", comment: "Days remaining number")
                .font(.system(size: baseFontSize, weight: .bold, design: .default))
                .lineLimit(1)
                .minimumScaleFactor(0.7) // More aggressive scaling
                .frame(maxWidth: .infinity)
                .frame(minHeight: 60)
                .accessibilityLabel(String(localized: "days_remaining", defaultValue: "Verbleibende Tage"))
                .accessibilityValue("\(daysRemaining)")
            
            Text("Tage verbleibend", comment: "Days label")
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding()
    }
}