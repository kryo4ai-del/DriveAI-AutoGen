// Tests/KIIdentifikation/Domain/UseCases/RecognizeSignUseCaseTests.swift
class RecognizeSignUseCaseTests: XCTestCase {
    var sut: DefaultRecognizeSignUseCase!
    var mockMLModel: MockTrafficSignMLModel!
    var mockRepository: MockTrafficSignRepository!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockMLModel = MockTrafficSignMLModel()
        mockRepository = MockTrafficSignRepository()
        sut = DefaultRecognizeSignUseCase(
            mlModel: mockMLModel,
            repository: mockRepository
        )
        cancellables = []
    }
    
    func test_execute_withHighConfidence_returnsRecognition() {
        // Arrange
        mockMLModel.stubbedPrediction = MLPrediction(
            labelId: "vorfahrt",
            confidence: 0.92,
            inferenceTimeMs: 420
        )
        
        // Act & Assert
        let expectation = XCTestExpectation(description: "recognizes sign")
        sut.execute(pixelBuffer: createMockPixelBuffer())
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { result in
                    XCTAssertEqual(result.confidence, 0.92)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
}