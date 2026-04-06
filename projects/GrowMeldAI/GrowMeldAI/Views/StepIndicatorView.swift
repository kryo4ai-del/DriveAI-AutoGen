// ✅ Scales with Dynamic Type
struct StepIndicatorView: View {
    @Environment(\.sizeCategory) var sizeCategory
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress bar (visual, not text)
            ProgressView(
                value: Double(currentStep),
                total: Double(totalSteps)
            )
            .accessibilityLabel("Fortschritt: Schritt \(currentStep) von \(totalSteps)")
            .accessibilityValue("\(Int((Double(currentStep) / Double(totalSteps)) * 100))%")
            
            // Text scales automatically
            Text("Schritt \(currentStep) von \(totalSteps)")
                .font(sizeCategory > .large ? .headline : .body)  // Larger for accessibility
                .accessibilityAddTraits(.isHeader)
            
            // Multi-line support for large accessibility sizes
            if sizeCategory >= .extraLarge {
                Text("Schritt").font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}