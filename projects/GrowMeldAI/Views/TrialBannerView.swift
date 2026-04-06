struct TrialBannerView: View {
    let subscription: UserSubscription
    
    @Environment(\.sizeCategory) var sizeCategory  // ✅ Observe Dynamic Type
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Testversion")
                        .font(.headline)  // ✅ Semantic font (scales with Dynamic Type)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text(subscription.state.displayText)
                        .font(.body)  // ✅ Semantic
                }
                
                Spacer()
                
                // Days counter with responsive size
                ZStack {
                    Circle()
                        .fill(Color(red: 0.95, green: 0.2, blue: 0.2))
                    
                    VStack(spacing: 0) {
                        Text("\(subscription.daysRemaining)")
                            .font(.system(.title2, design: .monospaced))  // ✅ Scales
                            .fontWeight(.bold)
                        
                        Text("Tage")
                            .font(.caption)  // ✅ Scales
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                }
                .frame(
                    width: sizeCategory > .large ? 60 : 48,  // Responsive sizing
                    height: sizeCategory > .large ? 60 : 48
                )
                .accessibilityLabel("\(subscription.daysRemaining) Tage verbleibend")
            }
            .padding(.all, sizeCategory > .large ? 16 : 12)
            .background(Color(red: 0.9, green: 0.15, blue: 0.15).opacity(0.1))
            .cornerRadius(8)
        }
        .accessibilityElement(children: .combine)
    }
}