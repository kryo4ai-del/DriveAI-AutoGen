struct AIStatusBadge: View {
    let status: AIServiceStatus
    
    var body: some View {
        switch status {
        case .online:
            Label("AI Enabled", systemImage: "bolt.fill")
                .foregroundColor(.green)
        case .offline:
            Label("Offline Mode", systemImage: "wifi.slash")
                .foregroundColor(.orange)
        case .degraded:
            Label("Limited Features", systemImage: "exclamationmark.triangle")
                .foregroundColor(.yellow)
        }
    }
}