struct PurchaseCheckoutView: View {
    @State var selectedFeature: PremiumFeature = .unlimitedExams
    
    var body: some View {
        VStack(spacing: 24) {
            // ✅ FIXED: Proper spacing and size
            PriceDisplayView(feature: selectedFeature)
            
            Button(action: { /* purchase */ }) {
                HStack {
                    Image(systemName: "bag.badge.plus")
                        .font(.system(size: 18))
                    
                    Text("Now kaufen")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)  // ✅ Exceeds 44pt minimum
                .foregroundColor(.white)
                .background(.blue)
                .cornerRadius(8)
            }
            // ✅ FIXED: Touch target includes padding
            .padding(.horizontal)
            .accessibilityLabel("Purchase \(selectedFeature.displayName)")
            .accessibilityHint("Double-tap to buy \(selectedFeature.displayName) for €\(selectedFeature.fallbackPriceEUR, specifier: "%.2f")")
        }
        .padding()
    }
}

struct PriceDisplayView: View {
    let feature: PremiumFeature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preis")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("€\(feature.fallbackPriceEUR, specifier: "%.2f")")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .monospacedDigit()  // ✅ Improves readability
                
                Text(priceBreakdown)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            // ✅ Tap area includes entire HStack (min 44pt height)
            .frame(minHeight: 44)
            .contentShape(Rectangle())  // Expand tap area
            .accessibilityLabel("Price: \(priceBreakdown)")
        }
    }
    
    private var priceBreakdown: String {
        // German VAT included
        let vatRate = 0.19  // 19% in Germany
        let netPrice = feature.fallbackPriceEUR / (1 + Decimal(vatRate))
        let vat = feature.fallbackPriceEUR - netPrice
        return String(localized: "incl. VAT €\(vat, specifier: "%.2f")", 
                     comment: "VAT breakdown")
    }
}