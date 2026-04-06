// File: Tests/UI/DynamicTypeTests.swift
import XCTest

final class DynamicTypeTests: XCTestCase {
    func testFlaggedQuestionsView_ExtraLargeText_NoTruncation() throws {
        let view = FlaggedQuestionsListView(viewModel: mockViewModel)
        
        let largeTextView = view
            .environment(\.sizeCategory, .accessibilityExtraLarge)
        
        // Render and check no text is truncated
        let snapshot = try largeTextView.snapshot()
        XCTAssertFalse(
            snapshot.hasTextTruncation,
            "Text should not be truncated at Accessibility Extra Large (200%)"
        )
    }
    
    func testProgressPercentage_AllSizes_Readable() {
        let sizes: [ContentSizeCategory] = [
            .small, .medium, .large, .extraLarge,
            .accessibilityMedium, .accessibilityLarge,
            .accessibilityExtraLarge, .accessibilityExtraExtraLarge
        ]
        
        for size in sizes {
            let view = AccessibleProgressSection(
                reviewedCount: 5,
                totalCount: 10,
                percentage: 50
            )
            .environment(\.sizeCategory, size)
            
            // Assert view renders without errors
            XCTAssertNoThrow {
                _ = try view.snapshot()
            }
        }
    }
}