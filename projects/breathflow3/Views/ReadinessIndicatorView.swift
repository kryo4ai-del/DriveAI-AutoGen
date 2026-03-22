struct ReadinessIndicatorView: View {
    let readiness: ReadinessStatus
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(readiness.color)
                .frame(width: 12, height: 12)
                .scaleEffect(isAnimating && !reduceMotion ? 1.2 : 1.0)
                .animation(
                    reduceMotion ? nil : 
                    .easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            Text(readiness.displayText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(readiness.color)
                .lineLimit(1)
        }
        .onAppear {
            isAnimating = !reduceMotion
        }
    }
}