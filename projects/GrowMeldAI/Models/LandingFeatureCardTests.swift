class LandingFeatureCardTests: XCTestCase {
    let testCard = LandingFeatureCard(
        icon: "checkmark.circle.fill",
        title: "Offizielle Fragen",
        subtitle: "1.000+ aus dem TÜV-Katalog",
        accentColor: .green
    )
    
    @MainActor
    func test_featureCard_displaysIcon_withAccentColor() {
        // GIVEN: Feature card with icon
        // WHEN: Rendered
        // THEN: Icon color = accentColor (green for checkmark)
        // Icon background opacity = 15%
    }
    
    @MainActor
    func test_featureCard_displaysTitle_andSubtitle() {
        // GIVEN: Feature card
        // WHEN: Rendered
        // THEN: Title font = 16pt bold
        // Subtitle font = 13pt regular, lineLimit = 3
    }
    
    @MainActor
    func test_featureCard_minHeight_140pt() {
        // GIVEN: Feature card
        // WHEN: Rendered
        // THEN: minHeight = 140pt
        // Content aligns to top-left
    }
    
    @MainActor
    func test_featureCard_backgroundColor_systemGray6() {
        // GIVEN: Feature card
        // WHEN: Light/dark mode
        // THEN: Background = Color(.systemGray6)
        // Adapts automatically to system appearance
    }
}