struct AccessiblePaywallView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            VStack(spacing: 12) {
                // Monthly Tier
                TierButton(
                    title: "Monthly",
                    price: "€9.99",
                    priceLabel: "€9.99 per month",
                    perUnitCost: "€9.99 per month",  // ✅ Clear cost
                    isPopular: false
                )
                
                // 3-Month Tier (Recommended)
                TierButton(
                    title: "3-Month Plan",
                    price: "€24.99",
                    priceLabel: "€24.99 total (€8.33/month)",  // ✅ Cost breakdown
                    perUnitCost: "€8.33 per month (saves 17%)",
                    isPopular: true
                )
                .accessibilityAddTraits(.startsMediaSession)  // Emphasize recommendation
                
                // Yearly Tier
                TierButton(
                    title: "Yearly Plan",
                    price: "€79.99",
                    priceLabel: "€79.99 total (€6.67/month)",  // ✅ Cost breakdown
                    perUnitCost: "€6.67 per month (saves 33%)",
                    isPopular: false
                )
            }
        }
    }
}

struct TierButton: View {
    let title: String
    let price: String
    let priceLabel: String
    let perUnitCost: String
    let isPopular: Bool
    
    var body: some View {
        Button(action: { /* select tier */ }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.body.weight(.semibold))
                    
                    if isPopular {
                        Spacer()
                        Text("Most Popular")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.green)
                            .cornerRadius(4)
                            .accessibilityHidden(false)  // Spoken by VoiceOver
                    }
                }
                
                Text(priceLabel)
                    .font(.title3.weight(.semibold))
                    .accessibilityLabel(perUnitCost)  // ✅ Speak value-per-month
                
                Text("Cancel anytime")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .frame(minHeight: 44)  // ✅ Touch target
        .accessibilityLabel("\(title) plan, \(priceLabel)")
        .accessibilityValue(isPopular ? "Most popular option" : "")
    }
}