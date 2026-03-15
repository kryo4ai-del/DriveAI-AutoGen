struct ResultsView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var showScore = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Assessment Complete")
                .font(.title2.bold())
            
            Text("\(assessment.passPercentage, format: .number.precision(.fractionLength(0)))%")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(assessment.readinessLevel.color)
                .scaleEffect(showScore ? 1.0 : 0.8)
                .animation(
                    reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.7),
                    value: showScore
                )
            
            ReadinessLevelBadge(level: assessment.readinessLevel)
                .opacity(showScore ? 1 : 0)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 0.3).delay(0.2),
                    value: showScore
                )
        }
        .onAppear {
            showScore = true
        }
    }
}