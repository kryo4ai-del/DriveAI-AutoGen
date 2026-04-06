import Foundation
import Combine
class DeepLinkRouter: ObservableObject {
    static let shared = DeepLinkRouter()
    @Published var pendingTarget: DeepLinkTarget?
    private let lock = NSLock()
    
    /// Handle incoming deep link from ASA or universal link
    func handleDeepLink(url: URL) {
        guard let target = DeepLinkTarget.parse(url: url) else {
            #if DEBUG
            print("[DeepLink] ❌ Failed to parse: \(url.absoluteString)")
            #endif
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.pendingTarget = target
            #if DEBUG
            print("[DeepLink] ✅ Routed to: \(target)")
            #endif
        }
    }
    
    /// Retrieve and clear pending deep link (main-thread safe)
    func popPendingTarget() -> DeepLinkTarget? {
        lock.lock()
        defer { lock.unlock() }
        
        let target = pendingTarget
        DispatchQueue.main.async { [weak self] in
            self?.pendingTarget = nil
        }
        return target
    }
    
    /// Clear pending deep link without returning
    func clearPending() {
        lock.lock()
        defer { lock.unlock() }
        
        DispatchQueue.main.async { [weak self] in
            self?.pendingTarget = nil
        }
    }
}