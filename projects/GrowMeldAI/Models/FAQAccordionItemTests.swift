class FAQAccordionItemTests: XCTestCase {
    let testItem = FAQItem(
        question: "Sind die Fragen offizielle TÜV-Fragen?",
        answer: "Ja! Wir nutzen den aktuellen TÜV-Katalog 2024..."
    )
    
    @MainActor
    func test_accordionItem_collapsedState_showsQuestionOnly() {
        // GIVEN: FAQ accordion, collapsed
        @State var isExpanded = false
        let sut = FAQAccordionItem(item: testItem)
        
        // WHEN: Rendered
        // THEN: Question visible
        // Answer hidden
        // Chevron icon points right
    }
    
    @MainActor
    func test_accordionItem_expandedState_showsAnswerBelow() {
        // GIVEN: FAQ accordion, expanded
        // WHEN: User taps question
        // THEN: withAnimation(.easeInOut(0.2)) triggers
        // Answer appears below (not above)
        // Chevron rotates 90°
    }
    
    @MainActor
    func test_accordionItem_toggle_animatesSmootly() {
        // GIVEN: Collapsed FAQ item
        // WHEN: User taps to expand
        // THEN: Animation duration = 0.2s (easeInOut)
        // Chevron rotation is synchronized
    }
}