// Services/FeatureFlags/FeatureFlagService.swift

import FirebaseRemoteConfig

protocol FeatureFlagServiceProtocol: AnyObject {
    func getValue(_ flag: String) -> String?
    func getVariant(experiment: String, userId: String) async -> String
    func isFeatureEnabled(_ feature: String) -> Bool
}

class RemoteConfigFeatureFlagService: NSObject, FeatureFlagServiceProtocol {
    private let remoteConfig = RemoteConfig.remoteConfig()
    private let variantCache = NSCache<NSString, NSString>()
    private let cache = NSCache<NSString, NSString>()
    
    private var lastFetchTime: Date = Date(timeIntervalSince1970: 0)
    private let fetchIntervalSeconds: TimeInterval = 3600 // 1 hour
    
    override init() {
        super.init()
        
        // Configure RemoteConfig
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = fetchIntervalSeconds
        remoteConfig.configSettings = settings
        
        // Set default values (fallback for offline)
        setDefaults()
        
        // Fetch on init
        Task {
            await fetchRemoteConfig()
        }
    }
    
    private func setDefaults() {
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }
    
    private func fetchRemoteConfig() async {
        do {
            let status = try await remoteConfig.fetchAndActivate()
            print("RemoteConfig fetch status: \(status.rawValue)")
        } catch {
            print("RemoteConfig fetch failed: \(error)")
        }
    }
    
    func getValue(_ flag: String) -> String? {
        // Check memory cache first
        if let cached = cache.object(forKey: flag as NSString) {
            return cached as String
        }
        
        // Fetch from RemoteConfig
        let value = remoteConfig.configValue(forKey: flag).stringValue
        
        if let value = value {
            cache.setObject(value as NSString, forKey: flag as NSString)
        }
        
        return value
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
        
        // Log variant assignment
        await EventBus.shared.post(
            .variantAssigned(experiment: experiment, variant: variant)
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