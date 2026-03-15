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
// [FK-019 sanitized] @EnvironmentObject var offlineStatus: OfflineStatusViewModel

// [FK-019 sanitized] var body: some View {
// [FK-019 sanitized]     VStack {
// [FK-019 sanitized]         if !offlineStatus.isOnline {
// [FK-019 sanitized]             HStack {
// [FK-019 sanitized]                 Image(systemName: "wifi.slash")
// [FK-019 sanitized]                 Text("Offline-Modus (Daten vom \(offlineStatus.lastSyncTime?.formatted() ?? "—"))")
// [FK-019 sanitized]                     .font(.caption)
// [FK-019 sanitized]             }
// [FK-019 sanitized]             .padding(8)
// [FK-019 sanitized]             .background(Color.orange.opacity(0.2))
// [FK-019 sanitized]         }
// [FK-019 sanitized]     }
// [FK-019 sanitized] }