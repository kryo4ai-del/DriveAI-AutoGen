import XCTest
import Combine
@testable import DriveAI

class QuestionCategoryViewModelTests: XCTestCase {
    var viewModel: QuestionCategoryViewModel!
    var localDataService: MockLocalDataService!

    class MockLocalDataService: QuestionCategoryService {
        func fetchQuestionCategories(completion: @escaping ([QuestionCategory]) -> Void) {
            let mockCategories = [
                QuestionCategory(id: UUID(), name: "Test Category 1", questionCount: 5),
                QuestionCategory(id: UUID(), name: "Test Category 2", questionCount: 10)
            ]
            completion(mockCategories)
        }
    }

    override func setUp() {
        super.setUp()
        localDataService = MockLocalDataService()
        viewModel = QuestionCategoryViewModel(localDataService: localDataService)
    }
    
    func testFetchCategoriesPopulatesCategories() {
        viewModel.fetchCategories()
        XCTAssertEqual(viewModel.categories.count, 2)
        XCTAssertEqual(viewModel.categories[0].name, "Test Category 1")
    }

    func testCategoriesArePublished() {
        let expectation = self.expectation(description: "Categories should be published")
        let cancellable = viewModel.$categories.sink { categories in
            if categories.count > 0 {
                XCTAssertEqual(categories.count, 2)
                expectation.fulfill()
            }
        }
        viewModel.fetchCategories()
        waitForExpectations(timeout: 1, handler: nil)
        cancellable.cancel()
    }
}