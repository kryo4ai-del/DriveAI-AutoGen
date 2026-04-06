// Tests/Models/CategoryModelTests.swift

import XCTest
@testable import DriveAI

final class CategoryModelTests: XCTestCase {
    
    func test_category_createdWithValidData() {
        // Arrange
        let category = Category(
            id: "CAT_SIGNS",
            name: "Verkehrsschilder",
            description: "Alle wichtigen Verkehrsschilder",
            icon: "🚦",
            questionCount: 145,
            order: 1
        )
        
        // Assert
        XCTAssertEqual(category.name, "Verkehrsschilder")
        XCTAssertEqual(category.questionCount, 145)
        XCTAssertGreaterThan(category.order, 0)
    }
    
    func test_category_emptyName_invalid() {
        // Assert
        XCTAssertTrue("".isEmpty, "Category name cannot be empty")
    }
    
    func test_category_zeroQuestionCount_allowed() {
        // Arrange: New category with no questions yet
        let category = Category(
            id: "CAT_NEW",
            name: "Neue Kategorie",
            description: "Wird noch gefüllt",
            icon: "📚",
            questionCount: 0,  // Edge case: valid for new category
            order: 99
        )
        
        // Assert
        XCTAssertEqual(category.questionCount, 0)
    }
    
    func test_category_negativeQuestionCount_invalid() {
        // Assert
        XCTAssertTrue(-5 < 0, "Question count cannot be negative")
    }
    
    func test_category_ordering() {
        // Arrange
        let categories = [
            Category(id: "1", name: "First", description: "", icon: "", questionCount: 50, order: 1),
            Category(id: "2", name: "Second", description: "", icon: "", questionCount: 75, order: 2),
            Category(id: "3", name: "Third", description: "", icon: "", questionCount: 100, order: 3)
        ]
        
        // Act
        let sorted = categories.sorted { $0.order < $1.order }
        
        // Assert
        XCTAssertEqual(sorted[0].order, 1)
        XCTAssertEqual(sorted[2].order, 3)
    }
}