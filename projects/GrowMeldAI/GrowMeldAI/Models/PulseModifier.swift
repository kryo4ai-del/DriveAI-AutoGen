struct PulseModifier: ViewModifier {
    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion ? 1.0 : (isAnimating ? 0.6 : 1.0))
            .animation(
                reduceMotion 
                    ? nil  // ✅ FIX: No animation if reduced motion enabled
                    : Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                if !reduceMotion {
                    isAnimating = true
                }
            }
    }
}