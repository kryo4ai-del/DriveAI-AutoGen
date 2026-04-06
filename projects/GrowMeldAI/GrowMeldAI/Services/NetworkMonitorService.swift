// Services/Backup/NetworkMonitorService.swift

import Combine
import Network

/// Monitors network reachability and notifies observers of connection changes
@MainActor
final class NetworkMonitorService: ObservableObject {
    static let shared = NetworkMonitorService()
    
    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType? = nil
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.driveai.network-monitor")
    
    // Closure-based observer (for non-Combine code)
    var onConnectionChange: ((Bool) -> Void)?
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateConnectionStatus(path)
            }
        }
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    // MARK: - Private Helpers
    
    private func updateConnectionStatus(_ path: NWPath) {
        let newStatus = path.status == .satisfied
        let oldStatus = isConnected
        
        isConnected = newStatus
        connectionType = path.availableInterfaces.first?.type
        
        // Notify listeners if status changed
        if newStatus != oldStatus {
            onConnectionChange?(newStatus)
        }
    }
}