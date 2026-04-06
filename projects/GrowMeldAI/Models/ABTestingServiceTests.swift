import XCTest
@testable import DriveAI

class ABTestingServiceTests: XCTestCase {
    var sut: ABTestingService!
    var mockRepository: MockABTestRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockABTestRepository()
        sut = ABTestingService(repository: mockRepository, 
                              userSegmentation: .shared)
    }
    
    func test_assignVariant_returnsSameVariantForSameUser() {
        // Given
        let testID = "test_v1"
        let test = ABTest(
            id: testID,
            name: "Test",
            variants: [
                TestVariant(id: "A", name: "Control", percentile: 50),
                TestVariant(id: "B", name: "Variant", percentile: 50)
            ]
        )
        mockRepository.tests[testID] = test
        
        // When
        let variant1 = sut.assignVariant(testID: testID)
        let variant2 = sut.assignVariant(testID: testID)
        
        // Then
        XCTAssertEqual(variant1?.id, variant2?.id, "Same user should get same variant")
    }
}