// ✅ FIXED
struct RetryQueueStatusView: View {
    @ObservedObject var retryQueue: RetryQueue
    @State private var isExpanded = false
    
    var body: some View {
        if !retryQueue.pendingRequests.isEmpty {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.blue)
                        .accessibilityLabel("Ausstehende Synchronisierung")
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daten werden synchronisiert")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Text(
                            "\(retryQueue.pendingRequests.count) Element\(retryQueue.pendingRequests.count == 1 ? "" : "e") ausstehend"
                        )
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { withAnimation { isExpanded.toggle() } }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .accessibilityLabel(isExpanded ? "Ausblenden" : "Details anzeigen")
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(retryQueue.pendingRequests, id: \.id) { request in
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .accessibilityHidden(true)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(request.endpoint)
                                        .font(.caption)
                                        .lineLimit(1)
                                    
                                    Text("Wiederholung: \(request.retryCount)/5")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .accessibilityLabel("Versuch \(request.retryCount) von 5")
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityValue("Ausstehend")
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.05))
            .border(Color.blue.opacity(0.2), width: 1)
            .cornerRadius(8)
            // ✅ MAIN ANNOUNCEMENT
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Synchronisierungsstatus")
            .accessibilityValue(
                "\(retryQueue.pendingRequests.count) Element\(retryQueue.pendingRequests.count == 1 ? "" : "e") warten auf Synchronisierung"
            )
            .accessibilityHint("Tippen, um Details zu sehen. Wird automatisch wiederhergestellt, wenn Netzwerk verfügbar ist.")
        }
    }
}