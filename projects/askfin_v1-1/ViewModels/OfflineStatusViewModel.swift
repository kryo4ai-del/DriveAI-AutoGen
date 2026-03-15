@MainActor
final class OfflineStatusViewModel: ObservableObject {
    @Published var isOnline = true
    @Published var lastSyncTime: Date?
    
    func checkConnectivity() {
        // Use Network framework
        isOnline = NetworkMonitor.shared.isConnected
        lastSyncTime = UserDefaults.standard.object(forKey: "lastDataSync") as? Date
    }
}

// In views:
@EnvironmentObject var offlineStatus: OfflineStatusViewModel

var body: some View {
    VStack {
        if !offlineStatus.isOnline {
            HStack {
                Image(systemName: "wifi.slash")
                Text("Offline-Modus (Daten vom \(offlineStatus.lastSyncTime?.formatted() ?? "—"))")
                    .font(.caption)
            }
            .padding(8)
            .background(Color.orange.opacity(0.2))
        }
    }
}