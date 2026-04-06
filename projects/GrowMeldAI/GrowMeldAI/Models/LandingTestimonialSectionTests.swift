class LandingTestimonialSectionTests: XCTestCase {
    @MainActor
    func test_testimonialSection_scrollsHorizontally_iPhone() {
        // GIVEN: iPhone (horizontalSizeClass = .compact)
        // WHEN: Testimonial section renders
        // THEN: ScrollView(.horizontal) active
        // Cards scroll left/right
    }
    
    @MainActor
    func test_testimonialSection_displaysAsGrid_iPad() {
        // GIVEN: iPad landscape (horizontalSizeClass = .regular)
        // WHEN: Testimonial section renders
        // THEN: ScrollView(.horizontal) disabled
        // Cards display in grid layout
    }
    
    @MainActor
    func test_testimonialSection_cardWidth_280pt_iPhone() {
        // GIVEN: Testimonial card on iPhone
        // WHEN: Rendered
        // THEN: .frame(width: 280)
        // Visible area: ~280pt + spacing
    }
    
    @MainActor
    func test_testimonialSection_paginationDots_visible() {
        // GIVEN: Testimonial carousel
        // WHEN: Rendered
        // THEN: Page dots visible below cards
        // Count = number of testimonials
        // Current dot highlighted
    }
}