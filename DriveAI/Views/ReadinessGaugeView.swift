struct ReadinessGaugeView: View {
    let readiness: Double  // 0–100
    
    @State private var animatedValue: Double = 0
    
    var colorZone: Color {
        switch readiness {
        case 0..<60: return .red
        case 60..<80: return .yellow
        default: return .green
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Canvas { context in
                // Circular gauge drawn here
                drawGauge(context: &context, value: animatedValue)
            }
            .frame(height: 200)
            
            VStack(spacing: 4) {
                Text("\(Int(readiness))%")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedValue = readiness
            }
        }
    }
    
    private func drawGauge(context: inout GraphicsContext, value: Double) {
        // Arc path, color zones, etc.
    }
}