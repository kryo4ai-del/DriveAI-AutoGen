class SKAdNetworkManager {
    static let shared = SKAdNetworkManager()
    
    private var currentConversionValue: Int = 0
    private let lock = NSLock()
    private let userDefaults = UserDefaults.standard
    private let conversionValueKey = "asa_current_conversion_value"
    
    init() {
        // Restore from persistent storage
        if let stored = userDefaults.dictionary(forKey: conversionValueKey),
           let value = stored["value"] as? Int {
            currentConversionValue = value
        }
    }
    
    /// Thread-safe conversion value update with persistence guarantee
    func updateConversionValue(_ value: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        let clampedValue = max(0, min(value, 100))
        
        // Only allow increments (SKAdNetwork constraint)
        guard clampedValue > currentConversionValue else {
            #if DEBUG
            print("[SKAdNetwork] ⚠️ Rejected (no increment): \(clampedValue) <= \(currentConversionValue)")
            #endif
            return
        }
        
        currentConversionValue = clampedValue
        
        // Synchronous UserDefaults write ensures durability
        var dict = userDefaults.dictionary(forKey: conversionValueKey) ?? [:]
        dict["value"] = clampedValue
        dict["timestamp"] = Date().timeIntervalSince1970
        userDefaults.set(dict, forKey: conversionValueKey)
        
        // Force synchronous write to disk
        if !userDefaults.synchronize() {
            #if DEBUG
            print("[SKAdNetwork] ❌ Failed to synchronize UserDefaults")
            #endif
        }
        
        // Then async SKAdNetwork update (doesn't block)
        Task { [weak self] in
            await self?.updateSKAdNetworkAsync(clampedValue)
        }
    }
    
    func resetForNewSession() {
        lock.lock()
        defer { lock.unlock() }
        
        currentConversionValue = 0
        userDefaults.removeObject(forKey: conversionValueKey)
        userDefaults.synchronize()
        
        #if DEBUG
        print("[SKAdNetwork] Reset for new session")
        #endif
    }
    
    @MainActor
    private func updateSKAdNetworkAsync(_ value: Int) async {
        do {
            try await SKAdNetwork.updateConversionValue(value)
            #if DEBUG
            print("[SKAdNetwork] ✅ Postback sent: \(value)")
            #endif
        } catch {
            #if DEBUG
            print("[SKAdNetwork] ❌ Error: \(error.localizedDescription)")
            #endif
        }
    }
}