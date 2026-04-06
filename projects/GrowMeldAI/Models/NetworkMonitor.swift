import Foundation
import Network

/// Monitors network connectivity using iOS built-in Network framework.
/// Published for reactive UI updates.
@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published private(set) var isConnected = true
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.driveai.network.monitor")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? true
                let isNowConnected = path.status == .satisfied
                
                if wasConnected != isNowConnected {
                    self?.isConnected = isNowConnected
                    #if DEBUG
                    print(isNowConnected ? "🌐 Network connected" : "📡 Network disconnected")
                    #endif
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}