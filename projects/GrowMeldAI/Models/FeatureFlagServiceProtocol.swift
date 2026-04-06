// Services/FeatureFlags/FeatureFlagService.swift

import Foundation

protocol FeatureFlagServiceProtocol: AnyObject {
    func getValue(_ flag: String) -> String?
    func getVariant(experiment: String, userId: String) async -> String
    func isFeatureEnabled(_ feature: String) -> Bool
}

class RemoteConfigFeatureFlagService: NSObject, FeatureFlagServiceProtocol {
    private let variantCache = NSCache<NSString, NSString>()
    private let cache = NSCache<NSString, NSString>()
    private var defaults: [String: String] = [:]
    
    private var lastFetchTime: Date = Date(timeIntervalSince1970: 0)
    private let fetchIntervalSeconds: TimeInterval = 3600 // 1 hour
    
    override init() {
        super.init()
        
        // Load defaults from plist if available
        loadDefaults()
    }
    
    private func loadDefaults() {
        if let path = Bundle.main.path(forResource: "RemoteConfigDefaults", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            defaults = dict
        }
    }
    
    func getValue(_ flag: String) -> String? {
        // Check memory cache first
        if let cached = cache.object(forKey: flag as NSString) {
            return cached as String
        }
        
        // Check UserDefaults for persisted values
        if let persisted = UserDefaults.standard.string(forKey: "remote_config_\(flag)") {
            cache.setObject(persisted as NSString, forKey: flag as NSString)
            return persisted
        }
        
        // Fall back to defaults
        if let defaultValue = defaults[flag] {
            cache.setObject(defaultValue as NSString, forKey: flag as NSString)
            return defaultValue
        }
        
        return nil
    }
    
    func isFeatureEnabled(_ feature: String) -> Bool {
        guard let value = getValue(feature) else { return false }
        return value.lowercased() == "true"
    }
    
    func getVariant(experiment: String, userId: String) async -> String {
        let cacheKey = "\(experiment)_\(userId)"
        
        // Check cache first
        if let cached = variantCache.object(forKey: cacheKey as NSString) {
            return cached as String
        }
        
        // Check UserDefaults for offline access
        if let persisted = UserDefaults.standard.string(forKey: "ab_test_\(cacheKey)") {
            variantCache.setObject(persisted as NSString, forKey: cacheKey as NSString)
            return persisted
        }
        
        // Deterministic assignment (same user always sees same variant)
        let variants = getExperimentVariants(experiment)
        let variant = deterministicVariantAssignment(
            userId: userId,
            experiment: experiment,
            variants: variants
        )
        
        // Cache locally
        variantCache.setObject(variant as NSString, forKey: cacheKey as NSString)
        
        // Also persist to UserDefaults for offline access
        UserDefaults.standard.setValue(
            variant,
            forKey: "ab_test_\(cacheKey)"
        )
        
        return variant
    }
    
    private func getExperimentVariants(_ experiment: String) -> [String] {
        let flagKey = "\(experiment)_variants"
        
        if let variantsString = getValue(flagKey) {
            return variantsString.split(separator: ",").map(String.init)
        }
        
        // Default variants
        switch experiment {
        case "paywall_copy_test":
            return ["control", "emotional", "functional", "urgency"]
        case "onboarding_length":
            return ["control", "variant_short"]
        default:
            return ["control"]
        }
    }
    
    private func deterministicVariantAssignment(
        userId: String,
        experiment: String,
        variants: [String]
    ) -> String {
        // Hash user ID + experiment to ensure consistency
        let combined = userId + experiment
        let hash = combined.hashValue
        let index = abs(hash) % variants.count
        return variants[index]
    }
}