// ❌ BAD
let features: [FeatureItem] = [
    FeatureItem(...),
    // ...
]

// ✅ GOOD
// Services/LandingContentService.swift
class LandingContentService {
    static let shared = LandingContentService()
    
    func getFeatures() -> [FeatureItem] {
        // Load from JSON or external source
    }
}