// Tests/KIIdentifikation/Unit/Infrastructure/MLModels/TrafficSignMLModelTests.swift

import XCTest
import Combine
@testable import DriveAI

class TrafficSignMLModelTests: XCTestCase {
    var sut: TrafficSignMLModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = TrafficSignMLModel()
        cancellables = []
        
        // Give model time to load
        XCTAssertTrue(waitForCondition({sut.isModelLoaded}, timeout: 5.0))
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        cancellables.removeAll()
    }
    
    // MARK: - Happy Path
    
    func test_predict_withValidPixelBuffer_returnsValidPrediction() {
        // Arrange
        let pixelBuffer = createMockPixelBuffer(width: 640, height: 640)
        
        // Act
        let prediction = sut.predict(pixelBuffer: pixelBuffer)
        
        // Assert
        XCTAssertFalse(prediction.labelId.isEmpty)
        XCTAssertGreaterThan(prediction.confidence, 0)
        XCTAssertLessThanOrEqual(prediction.confidence, 1.0)
        XCTAssertGreaterThan(prediction.inferenceTimeMs, 0)
        XCTAssertLessThan(prediction.inferenceTimeMs, 1000) // Should be <1s
    }
    
    func test_predict_inferenceTimeBelowThreshold() {
        // Arrange
        let pixelBuffer = createMockPixelBuffer(width: 640, height: 640)
        
        // Act
        let predictions = (0..<10).map { _ in sut.predict(pixelBuffer: pixelBuffer) }
        let avgTime = predictions.map { $0.inferenceTimeMs }.reduce(0, +) / predictions.count
        
        // Assert – Target <500ms per TASK-001 acceptance criteria
        XCTAssertLessThan(avgTime, 500, "Average inference time should be <500ms")
    }
    
    // MARK: - Edge Cases
    
    func test_predict_withDifferentResolutions_handles_gracefully() {
        // Arrange
        let resolutions = [(480, 480), (640, 640), (1280, 720)]
        
        // Act & Assert
        for (width, height) in resolutions {
            let pixelBuffer = createMockPixelBuffer(width: width, height: height)
            let prediction = sut.predict(pixelBuffer: pixelBuffer)
            
            XCTAssertGreaterThan(prediction.confidence, 0, "Should handle resolution \(width)x\(height)")
        }
    }
    
    func test_predict_withUnloadedModel_returnsEmptyPrediction() {
        // Arrange
        let modelWithoutLoading = TrafficSignMLModel()
        let pixelBuffer = createMockPixelBuffer(width: 640, height: 640)
        
        // Act
        let prediction = modelWithoutLoading.predict(pixelBuffer: pixelBuffer)
        
        // Assert
        XCTAssertEqual(prediction.labelId, "")
        XCTAssertEqual(prediction.confidence, 0)
    }
    
    func test_predict_consistencyAcrossFrames() {
        // Arrange – Same image passed twice
        let pixelBuffer = createMockPixelBuffer(width: 640, height: 640)
        
        // Act
        let prediction1 = sut.predict(pixelBuffer: pixelBuffer)
        let prediction2 = sut.predict(pixelBuffer: pixelBuffer)
        
        // Assert
        XCTAssertEqual(prediction1.labelId, prediction2.labelId)
        XCTAssertEqual(prediction1.confidence, prediction2.confidence, accuracy: 0.01)
    }
    
    // MARK: - Failure Cases
    
    func test_predict_withNullPixelBuffer_gracefullyHandles() {
        // This is defensive – CVPixelBuffer is non-null in Swift
        // But test that invalid dimensions are handled
        let pixelBuffer = createMockPixelBuffer(width: 1, height: 1)
        
        let prediction = sut.predict(pixelBuffer: pixelBuffer)
        
        // Should not crash
        XCTAssertGreaterThanOrEqual(prediction.confidence, 0)
    }
    
    // MARK: - Helpers
    
    private func createMockPixelBuffer(width: Int, height: Int) -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        
        XCTAssertEqual(status, kCVReturnSuccess)
        return pixelBuffer ?? CVPixelBufferCreate(kCFAllocatorDefault, 640, 640, kCVPixelFormatType_32BGRA, nil, &pixelBuffer) ?? pixelBuffer!
    }
    
    private func waitForCondition(_ condition: @escaping () -> Bool, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            Thread.sleep(forTimeInterval: 0.1)
        }
        return false
    }
}