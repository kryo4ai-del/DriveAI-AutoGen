import XCTest
import SwiftUI
import ViewInspector
@testable import DriveAI

extension QuestionCategoryView: Inspectable {}

class QuestionCategoryViewTests: XCTestCase {
    func testListDisplaysCategories() throws {
        let mockViewModel = MockQuestionCategoryViewModel()
        let view = QuestionCategoryView(viewModel: mockViewModel)
        
        mockViewModel.fetchCategories() // Simulate loading of categories
        
        let inspector = try view.inspect()
        let list = try inspector.find(ViewType.List.self)
        
        XCTAssertEqual(try list.count(), 2) // Ensure categories loaded as expected
        
        // Validate the presence of category names
        let firstCategoryItem = try list.item(0).text().string()
        XCTAssertEqual(firstCategoryItem, "Test Category 1")
    }
}

class MockQuestionCategoryViewModel: QuestionCategoryViewModel {
    override func fetchCategories() {
        categories = [
            QuestionCategory(id: UUID(), name: "Test Category 1", questionCount: 5),
            QuestionCategory(id: UUID(), name: "Test Category 2", questionCount: 10)
        ]
    }
}