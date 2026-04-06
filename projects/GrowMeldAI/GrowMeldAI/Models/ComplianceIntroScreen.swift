struct ComplianceIntroScreen: View {
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ✅ Use dynamic sizes
            Text(NSLocalizedString("compliance.intro.title", comment: ""))
                .font(.system(.title, design: .default))
                .dynamicallyScaled()  // Custom modifier
                .padding(.horizontal)
            
            Text(NSLocalizedString("compliance.intro.description", comment: ""))
                .font(.system(.body, design: .default))
                .dynamicallyScaled()
                .lineLimit(nil)  // Allow wrapping at all sizes
                .padding(.horizontal)
            
            // Buttons scale too
            Button {
                // Action
            } label: {
                Text(NSLocalizedString("compliance.continue", comment: ""))
                    .font(.system(.headline, design: .default))
                    .dynamicallyScaled()
                    .frame(minHeight: 44)  // Minimum touch target
            }
            .padding()
        }
    }
}

// Helper modifier for consistent Dynamic Type scaling
extension View {
    func dynamicallyScaled() -> some View {
        self.lineLimit(nil)
            .truncationMode(.tail)
    }
}