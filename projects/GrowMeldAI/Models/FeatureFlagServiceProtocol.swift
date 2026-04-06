import Foundation

protocol FeatureFlagServiceProtocol: AnyObject {
    func getValue(_ flag: String) -> String?
    func getVariant(experiment: String, userId: String) async -> String
    func isFeatureEnabled(_ feature: String) -> Bool
}

class RemoteConfigFeatureFlagService: NSObject, FeatureFlagServiceProtocol {
    private let variantCache = NSCache<NSString, NSString>()
    private let cache = NSCache<NSString, NSString>()
    private let defaults = UserDefaults.standard

    override init() {
        super.init()
    }

    func getValue(_ flag: String) -> String? {
        if let cached = cache.object(forKey: flag as NSString) {
            return cached as String
        }
        let value = defaults.string(forKey: "feature_flag_\(flag)")
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

        if let cached = variantCache.object(forKey: cacheKey as NSString) {
            return cached as String
        }

        let persistedKey = "ab_test_\(cacheKey)"
        if let persisted = defaults.string(forKey: persistedKey) {
            variantCache.setObject(persisted as NSString, forKey: cacheKey as NSString)
            return persisted
        }

        let variants = getExperimentVariants(experiment)
        let variant = deterministicVariantAssignment(
            userId: userId,
            experiment: experiment,
            variants: variants
        )

        variantCache.setObject(variant as NSString, forKey: cacheKey as NSString)
        defaults.setValue(variant, forKey: persistedKey)

        return variant
    }

    private func getExperimentVariants(_ experiment: String) -> [String] {
        let flagKey = "\(experiment)_variants"
        if let variantsString = getValue(flagKey) {
            return variantsString.split(separator: ",").map(String.init)
        }
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
        guard !variants.isEmpty else { return "control" }
        let combined = "\(userId):\(experiment)"
        var hash: UInt32 = 5381
        for char in combined.unicodeScalars {
            hash = hash &* 33 &+ char.value
        }
        let index = Int(hash) % variants.count
        return variants[abs(index)]
    }
}