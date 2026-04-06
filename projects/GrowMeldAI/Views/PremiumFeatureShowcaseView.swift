struct PremiumFeatureShowcaseView: View {
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(feature.displayName)
                .font(.headline)
                // ✅ FIXED: Dynamic Type respects user settings
                .lineLimit(2)  // Allow wrap, not truncate
                .minimumScaleFactor(0.8)  // Fallback for very large sizes
            
            Text(feature.description)
                .font(.body)
                // ✅ FIXED: Responsive spacing
                .lineLimit(.max)
                .fixedSize(horizontal: false, vertical: true)  // Expand vertically if needed
            
            // ✅ FIXED: Hide less important content on very large sizes
            if !sizeCategory.isAccessibilityCategory {
                HStack {
                    Image(systemName: feature.icon)
                        .font(.system(size: 24))
                    Spacer()
                }
            }
        }
        .padding()
        // ✅ FIXED: Responsive padding
        .padding(.vertical, sizeCategory > .large ? 16 : 8)
    }
}

// Test in XCode: Cmd+Shift+A → Accessibility Inspector → Text Size
// Should work from "Small" (11pt) to "AX Extra Large" (19pt)