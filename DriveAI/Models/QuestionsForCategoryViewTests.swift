import XCTest
import SwiftUI
import ViewInspector
@testable import DriveAI

extension QuestionsForCategoryView: Inspectable {}

class QuestionsForCategoryViewTests: XCTestCase {
    func testDisplaysCategoryName() throws {
        let category = QuestionCategory(id: UUID(), name: "Traffic Signs", questionCount: 15)
        let view = QuestionsForCategoryView(category: category)
        
        let inspector = try view.inspect()
        let text = try inspector.find(text: "Fragen für Traffic Signs")
        XCTAssertNotNil(text)
        
        // Validate button presence and its title
        let button = try inspector.find(ViewType.Button.self)
        XCTAssertNotNil(button)
        XCTAssertEqual(try button.label().string(), "Start")
    }
}