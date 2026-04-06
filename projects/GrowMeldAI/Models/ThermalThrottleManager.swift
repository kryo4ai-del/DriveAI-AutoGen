// ❌ DEAD CODE: Defined but never called
class ThermalThrottleManager {
    func shouldThrottle() -> Bool {
        ProcessInfo.processInfo.thermalState >= .critical
    }
}

// Nowhere in ViewModel: 
// - No subscription to thermal notifications
// - No frame skipping logic
// - No user feedback