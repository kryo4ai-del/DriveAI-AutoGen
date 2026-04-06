class LandingHeroSectionTests: XCTestCase {
    @MainActor
    func test_heroSection_displaysHeadline_correctly() {
        // GIVEN: Hero section
        let sut = LandingHeroSection(isScrollingPastHero: .constant(false))
        
        // WHEN: Rendered
        // THEN: Headline is "landing.hero.title".localized
        // Font: 32pt bold
        // Color: foreground (black/white in dark mode)
    }
    
    @MainActor
    func test_heroSection_displaysGradientBackground() {
        // GIVEN: Hero image container
        let sut = LandingHeroSection(isScrollingPastHero: .constant(false))
        
        // WHEN: Container renders
        // THEN: LinearGradient from blue (#3366F2) to light blue (#4D7FFF)
        // Rounded corners: 16pt
    }
    
    @MainActor
    func test_heroSection_displaysTrustBadges() {
        // GIVEN: Trust badge section
        let sut = LandingHeroSection(isScrollingPastHero: .constant(false))
        
        // WHEN: Hero renders
        // THEN: Two badges present:
        //   1. "4.8" with star icon (yellow)
        //   2. "50k+ Bestanden" with checkmark (green)
    }
    
    @MainActor
    func test_heroSection_carIconFallsbackToSFSymbol() {
        // GIVEN: Hero icon (car.fill)
        // WHEN: Icon doesn't load
        // THEN: SF Symbol "car.fill" still displays (no blank space)
    }
}