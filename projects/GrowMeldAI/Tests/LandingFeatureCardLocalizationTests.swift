class LandingFeatureCardLocalizationTests: XCTestCase {
    @MainActor
    func test_featureCard_displaysLocalizedTitle() {
        // GIVEN: Feature card with title key "landing.feature.official.title"
        // WHEN: German locale selected
        // THEN: Title = "Offizielle Fragen"
        
        // WHEN: English locale selected
        // THEN: Title = "Official Questions"
    }
    
    @MainActor
    func test_featureCard_handles_longLocalizedText() {
        // GIVEN: Feature card with long German subtitle
        // E.g., "Trainiere mit über 1.000 Fragen aus dem offiziellen TÜV-Katalog"
        // WHEN: Rendered on iPhone SE (375pt width)
        // THEN: Text wraps (lineLimit = 3), no truncation
    }
}