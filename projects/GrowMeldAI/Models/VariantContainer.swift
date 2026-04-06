struct VariantContainer<A: View, B: View>: View {
    @Environment(\.variantResolver) var variantResolver
    
    let experimentId: String
    let variantA: () -> A
    let variantB: () -> B
    let variantALabel: String  // e.g., "Horizontal Layout"
    let variantBLabel: String  // e.g., "Vertical Layout"
    
    var body: some View {
        let variant = variantResolver.resolveVariant(experimentId)
        
        ZStack {
            if variant == "variant_a" {
                variantA()
                    .accessibilityLabel(variantALabel)
                    .accessibilityValue("Currently active")
            } else {
                variantB()
                    .accessibilityLabel(variantBLabel)
                    .accessibilityValue("Currently active")
            }
        }
        .accessibilityElement(children: .contain)  // Group for VoiceOver
    }
}