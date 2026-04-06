import Foundation

class SKAdNetworkManager {
    static let shared = SKAdNetworkManager()

    private var currentConversionValue: Int = 0
    private let lock = NSLock()
    private let userDefaults = UserDefaults.standard
    private let conversionValueKey = "asa_current_conversion_value"

    init() {
        if let stored = userDefaults.dictionary(forKey: conversionValueKey),
           let value = stored["value"] as? Int {
            currentConversionValue = value
        }
    }

    func updateConversionValue(_ value: Int) {
        lock.lock()
        defer { lock.unlock() }

        let clampedValue = max(0, min(value, 100))

        guard clampedValue > currentConversionValue else {
            #if DEBUG
            print("[SKAdNetwork] ⚠️ Rejected (no increment): \(clampedValue) <= \(currentConversionValue)")
            #endif
            return
        }

        currentConversionValue = clampedValue

        var dict = userDefaults.dictionary(forKey: conversionValueKey) ?? [:]
        dict["value"] = clampedValue
        dict["timestamp"] = Date().timeIntervalSince1970
        userDefaults.set(dict, forKey: conversionValueKey)
        userDefaults.synchronize()

        #if DEBUG
        print("[SKAdNetwork] ✅ Conversion value updated: \(clampedValue)")
        #endif
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

    func getCurrentConversionValue() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return currentConversionValue
    }
}