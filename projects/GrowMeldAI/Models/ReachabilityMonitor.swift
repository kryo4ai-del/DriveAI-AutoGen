import Network
import Combine
import Foundation

class ReachabilityMonitor: ObservableObject {
    @Published var isConnected: Bool = true
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.driveai.reachability")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                
                if path.status == .satisfied {
                    Logger.info("Network connected")
                } else {
                    Logger.warning("Network disconnected")
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}