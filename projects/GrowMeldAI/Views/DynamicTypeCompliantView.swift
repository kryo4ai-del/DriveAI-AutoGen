// Use Dynamic Type-relative modifiers
Text("Prüfungsbereitschaft")
    .font(.headline)  // ← This DOES respect Dynamic Type in SwiftUI 17+
    .lineLimit(nil)    // Allow text to wrap
    .minimumScaleFactor(0.8)  // Don't compress below 80%

// For custom sizes, use .relative approach:
Text("Category Name")
    .font(.system(size: 16, weight: .semibold, design: .default))
    .environment(\.sizeCategory, .large)  // ← Ties to Dynamic Type

// Better: Use semantic modifiers:
Text("Verkehrszeichen")
    .font(.subheadline)  // Respects Dynamic Type automatically
    .lineLimit(3)         // Allow wrapping instead of truncating

// Ensure all text scales with Dynamic Type:
struct DynamicTypeCompliantView: View {
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Primary Title")
                .font(.title2)  // Scales with Dynamic Type
                .lineLimit(nil)
            
            Text("Secondary info")
                .font(.body)  // Scales with Dynamic Type
                .lineLimit(nil)
            
            Text("Small caption")
                .font(.caption)  // Scales with Dynamic Type
                .lineLimit(nil)
        }
        .padding(16)
    }
}