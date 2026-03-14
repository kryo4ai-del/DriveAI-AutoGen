struct ReadinessScoreRingView: View {
    let percentage: Int
    let level: ReadinessLevel
    @State private var animatedPercentage = 0
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().stroke(Color.gray.opacity(0.2), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: CGFloat(animatedPercentage) / 100)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    // ✅ Respect motion preferences
                    .animation(
                        reduceMotion ? .linear(duration: 0.01) : .easeInOut(duration: 1),
                        value: animatedPercentage
                    )
                
                VStack(spacing: 4) {
                    // ✅ Dynamic Type support
                    Text("\(animatedPercentage)%")
                        .font(.system(.title, design: .default))
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.8) // Allow slight compression
                    
                    Text(level.label)
                        .font(.system(.body, design: .default))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Prüfungsbereitschaft")
            .accessibilityValue("\(animatedPercentage) Prozent, \(level.label)")
            .accessibilityHint("Ihr aktueller Bereitschaftsstand")
        }
        .onAppear {
            // ✅ Only animate if motion is not reduced
            if reduceMotion {
                animatedPercentage = percentage
            } else {
                withAnimation(.easeInOut(duration: 1)) {
                    animatedPercentage = percentage
                }
            }
        }
    }
    
    private var ringColor: Color {
        switch level {
        case .notReady: return .red
        case .partiallyReady: return .yellow
        case .ready: return .green
        case .excellent: return .blue
        }
    }
}