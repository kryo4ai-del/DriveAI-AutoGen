// ❌ Data mixed with UI logic
struct LandingFeatureGrid: View {
    let features: [FeatureItem] = [
        FeatureItem(...),
        FeatureItem(...),
        // ... 6 items hardcoded
    ]
}