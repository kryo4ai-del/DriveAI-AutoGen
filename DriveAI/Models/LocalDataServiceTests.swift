import XCTest
@testable import DriveAI

class LocalDataServiceTests: XCTestCase {
    var localDataService: LocalDataService!

    override func setUp() {
        super.setUp()
        localDataService = LocalDataService()
    }
    
    func testFetchQuestionCategories() {
        let expectation = self.expectation(description: "Fetch categories")
        localDataService.fetchQuestionCategories { categories in
            XCTAssertEqual(categories.count, 3)
            let expectedNames = ["Verkehrszeichen", "Vorfahrtsrecht", "Bußgelder"]
            XCTAssertEqual(categories.map { $0.name }, expectedNames)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
}