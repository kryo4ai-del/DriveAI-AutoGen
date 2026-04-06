@Environment(\.accessibilityReduceMotion) var reduceMotion

struct ReticleGuideView: View {
    var body: some View {
        VStack(spacing: 0) {
            // ... frame ...
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor, lineWidth: 3)
                    .opacity(reduceMotion ? 1.0 : 0.8)
                    // Optional subtle pulsing only if reduceMotion is false
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 1.5).repeatForever(),
                        value: reduceMotion
                    )
            }
        }
    }
}