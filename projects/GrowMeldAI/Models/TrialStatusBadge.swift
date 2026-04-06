struct TrialStatusBadge: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isPulsing = false
    
    var body: some View {
        HStack {
            Text("7 days")
                .scaleEffect(reduceMotion ? 1.0 : (isPulsing ? 1.1 : 1.0))
                .onAppear {
                    if !reduceMotion {
                        withAnimation(.easeInOut(duration: 2).repeatForever()) {
                            isPulsing = true
                        }
                    }
                }
        }
    }
}