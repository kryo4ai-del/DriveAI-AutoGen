struct PerformanceGaugeView: View {
    let accuracy: Double
    let readinessLevel: ReadinessLevel
    @State private var hasJustImproved = false
    
    var body: some View {
        ZStack {
            // ... existing gauge code ...
            
            // ✅ MICRO-ANIMATION: Celebratory pulse on improvement
            if hasJustImproved {
                Circle()
                    .strokeBorder(readinessLevel.color, lineWidth: 2)
                    .scaleEffect(1.1)
                    .opacity(0)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.6)) {
                            // Pulse outward
                        }
                    }
            }
        }
        .onReceive(Publishers.CombineLatest($viewModel.previousAccuracy, $viewModel.currentAccuracy)) { prev, curr in
            if curr > prev {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    hasJustImproved = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    hasJustImproved = false
                }
            }
        }
    }
}