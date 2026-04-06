struct OfflineIndicatorView: View {
    @ObservedObject var networkMonitor: NetworkMonitor
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        if !networkMonitor.isOnline {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .accessibilityHidden(true)
                Text("Offline-Modus")
                Spacer().accessibilityHidden(true)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.8))
            .cornerRadius(4)
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
            // ✅ When reduce-motion is on, just fade (instant/no motion)
        }
    }
}