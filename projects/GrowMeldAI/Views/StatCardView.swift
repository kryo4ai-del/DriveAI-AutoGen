import SwiftUI
struct StatCardView: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: Image?
    let accentColor: Color
    let backgroundColor: Color
    let isInteractive: Bool = false  // New parameter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ... existing code ...
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(backgroundColor)
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        .accessibilityHint(subtitle ?? "")
        .accessibilityAddTraits(isInteractive ? .isButton : [])
    }
}