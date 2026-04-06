struct PricingCardView: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                Text(product.displayName)
                    .font(.headline)
                
                Text(product.displayPrice)
                    .font(.title3)
                
                if let periodString = product.subscription?.subscriptionPeriod.displayString {
                    Text("/" + periodString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .border(isSelected ? Color.blue : Color.clear, width: 2)
        }
        .accessibilityElement(children: .combine)  // ← Group all text into one element
        .accessibilityLabel(
            NSLocalizedString(
                "acc.pricing_card.label",
                comment: "Pricing card: {product_name}"
            ) + ": \(product.displayName)"
        )
        .accessibilityHint(
            isSelected
            ? NSLocalizedString(
                "acc.pricing_card.selected",
                comment: "This plan is currently selected"
            )
            : NSLocalizedString(
                "acc.pricing_card.select",
                comment: "Double-tap to select this plan"
            )
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityAddTraits(.isButton)
        
        // Add custom content for full plan details
        .accessibilityCustomContent(
            "price",
            product.displayPrice,
            importance: .high
        )
        .accessibilityCustomContent(
            "billingPeriod",
            product.subscription?.subscriptionPeriod.displayString ?? NSLocalizedString("acc.one_time", comment: "One-time purchase"),
            importance: .high
        )
    }
}