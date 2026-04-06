struct QuotaStatusView: View {
    @Environment(\.quotaManager) var quotaManager
    @Environment(\.sizeCategory) var sizeCategory  // ✅ Observe size changes
    
    var body: some View {
        VStack {
            Text(quotaManager.state.displayLabel)
                .font(.body)  // ✅ Use named font, scales automatically
                .lineLimit(nil)  // ✅ Allow multiple lines for large text
                .accessibilityLabel(accessibilityLabel)
        }
        // ✅ Test with accessibility settings:
        // Settings > Accessibility > Display & Text Size > Larger Accessibility Sizes
    }
    
    private var accessibilityLabel: String {
        // Provide verbatim label separate from visual display
        switch quotaManager.state {
        case .freeTierActive(let remaining):
            return "\(remaining) questions remaining today"
        default:
            return ""
        }
    }
}