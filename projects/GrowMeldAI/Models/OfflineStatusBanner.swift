struct OfflineStatusBanner: View {
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.orange)
                    .accessibilityLabel("Offline")
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Kein Netz? Kein Problem.")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .lineLimit(2, reservedSpace: 20)
                    
                    Text("\(syncQueue.pendingCount) Antworten warten auf Sync")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("\(syncQueue.pendingCount) answers waiting to sync")
                }
                .lineLimit(3)  // ✅ Respect Dynamic Type
                
                Spacer()
                
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isExpanded ? "Hide details" : "Show details")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Your answers are saved locally. They'll sync when you're online.")
    }
}