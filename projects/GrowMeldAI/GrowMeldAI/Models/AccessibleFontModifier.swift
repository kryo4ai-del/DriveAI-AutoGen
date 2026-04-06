struct AccessibleFontModifier: ViewModifier {
    enum FontSize {
        case largeTitle, title, title2, title3, headline, body, callout, subheadline, footnote, caption, caption2
    }
    
    let size: FontSize
    let weight: Font.Weight
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: sizeValue, weight: weight, design: .default))
            .lineLimit(nil)  // Allow text wrapping
    }
    
    private var sizeValue: CGFloat {
        switch size {
        case .title2: return 22
        case .body: return 17
        // ... other cases
        }
    }
}