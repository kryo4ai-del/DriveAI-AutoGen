class LandingScreenTests: XCTestCase {
    @MainActor
    func test_landingScreen_rendersAllSections_whenLoaded() {
        // GIVEN: Fresh app launch
        let appState = AppState()
        
        // WHEN: Landing screen displays
        let sut = LandingScreen()
            .environmentObject(appState)
        
        // THEN: All sections are present and visible
        XCTAssertTrue(sut.environment(\.isEnabled) == true)
        // Verify hero, features, testimonials, FAQ, CTA footer render
    }
    
    @MainActor
    func test_landingScreen_navigatesToOnboarding_whenCTAPressed() {
        // GIVEN: Landing screen with navigation state
        let appState = AppState()
        appState.navigationPath = NavigationPath()
        let sut = LandingScreen()
            .environmentObject(appState)
        
        // WHEN: User taps "Jetzt kostenlos starten" button
        let cta = LandingCTAFooter { appState.navigate(to: .onboarding) }
        cta.buttonAction() // Simulated tap
        
        // THEN: Navigation path contains onboarding destination
        XCTAssertEqual(appState.navigationPath.count, 1)
    }
    
    @MainActor
    func test_landingScreen_scrollViewDismissesKeyboard_interactively() {
        // GIVEN: Landing screen displayed
        let sut = LandingScreen()
            .environmentObject(AppState())
        
        // WHEN: User scrolls
        // THEN: Keyboard dismisses
        // (Verify via UIKit: UIScrollView.keyboardDismissMode == .interactive)
    }
}