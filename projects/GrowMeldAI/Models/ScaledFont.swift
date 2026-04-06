// BEFORE (breaks at large sizes):
Text("Category Name")
    .font(.custom("SFProDisplay", size: 16))
    .frame(height: 20)

// AFTER (respects Dynamic Type):
Text("Category Name")
    .font(.headline) // Dynamic by default
    .lineLimit(2)
    .minimumScaleFactor(0.8) // Shrinks if needed, not cut off
    .padding(.vertical, 8)
    // NO fixed frame heights — use padding & spacing

// For custom fonts, use scaledFont:
struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    let size: CGFloat
    
    func body(content: Content) -> some View {
        let scaledSize = size * sizeCategory.scaleFactor
        return content.font(.system(size: scaledSize, weight: .semibold))
    }
}

extension View {
    func scaledFont(_ size: CGFloat) -> some View {
        self.modifier(ScaledFont(size: size))
    }
}