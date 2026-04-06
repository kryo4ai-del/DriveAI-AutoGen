// In XCTest, verify Dynamic Type scaling:
struct DynamicTypePreview: View {
    var body: some View {
        PremiumFeatureCard(
            product: mockProduct,
            isUnlocked: false,
            onPurchase: {}
        )
        .environment(\.sizeCategory, .accessibilityExtraLarge)  // Test at largest size
    }
}