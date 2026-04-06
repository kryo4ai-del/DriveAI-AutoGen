struct MaintenanceStatusView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        Button(action: { onTapAction?() }) {
            HStack {
                // ... content ...
            }
        }
        .contentTransition(.identity) // No animation by default
        .onChange(of: check.status) { oldStatus, newStatus in
            if !reduceMotion {
                // Only animate if user hasn't enabled Reduce Motion
                withAnimation(.easeInOut(duration: 0.3)) {
                    // Highlight change
                }
            }
        }
    }
}