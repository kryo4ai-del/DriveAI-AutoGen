struct FeatureFlagsSchema {
    static let currentVersion = 1
    static let versionKey = "featureFlags.version"
    
    // Backward-compatible key mapping
    static let keyMap: [String: String] = [
        "featureFlag.metaTracking": "features.meta.tracking",
        "featureFlag.skadnetwork": "features.skadnetwork"
    ]
}
