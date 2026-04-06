// Tests/KIIdentifikation/Unit/Infrastructure/MLModels/ConfidenceSmootherTests.swift

import XCTest
@testable import DriveAI

class ConfidenceSmootherTests: XCTestCase {
    var sut: ConfidenceSmoother!
    
    override func setUp() {
        super.setUp()
        sut = ConfidenceSmoother()
    }
    
    // MARK: - Happy Path
    
    func test_smooth_withConsistentInput_convergesToInput() {
        // Arrange
        let targetConfidence: Float = 0.85
        let samples = Array(repeating: targetConfidence, count: 10)
        
        // Act
        let smoothed = samples.map { sut.smooth($0) }
        
        // Assert – Should converge towards target
        XCTAssertGreaterThan(smoothed.last ?? 0, 0.80)
        XCTAssertLessThan(smoothed.last ?? 1, 0.90)
    }
    
    func test_smooth_reducesNoise() {
        // Arrange – Noisy confidence (mimics real ML model)
        let noisy = [0.3, 0.92, 0.4, 0.88, 0.35, 0.90]
        
        // Act
        let smoothed = noisy.map { sut.smooth($0) }
        
        // Assert – Smoothed should have lower variance
        let noisyVariance = calculateVariance(noisy)
        let smoothedVariance = calculateVariance(smoothed)
        
        XCTAssertLessThan(smoothedVariance, noisyVariance * 0.3)
    }
    
    func test_smooth_eliminatesFlickers() {
        // Arrange – Pattern: high, low, high, low
        let flickering = [0.85, 0.3, 0.85, 0.3, 0.85, 0.3]
        
        // Act
        let smoothed = flickering.map { sut.smooth($0) }
        
        // Assert – Smoothed values should avoid extremes
        let extremeCount = smoothed.filter { $0 > 0.75 || $0 < 0.4 }.count
        XCTAssertLessThan(extremeCount, flickering.count / 2, "Should reduce flicker")
    }
    
    // MARK: - Edge Cases
    
    func test_smooth_firstValue_returnsSameValue() {
        // Act
        let smoothed = sut.smooth(0.75)
        
        // Assert
        XCTAssertEqual(smoothed, 0.75)
    }
    
    func test_smooth_withZero_handlesGracefully() {
        // Act
        _ = sut.smooth(0.8)
        let result = sut.smooth(0)
        
        // Assert – Should not crash, should move towards 0
        XCTAssertGreaterThan(result, 0) // But not zero yet
        XCTAssertLessThan(result, 0.8)
    }
    
    func test_smooth_withOne_handlesProperly() {
        // Act
        _ = sut.smooth(0.2)
        let result = sut.smooth(1.0)
        
        // Assert
        XCTAssertLessThan(result, 1.0)
        XCTAssertGreaterThan(result, 0.2)
    }
    
    func test_reset_clearsState() {
        // Arrange
        _ = sut.smooth(0.9)
        _ = sut.smooth(0.9)
        
        // Act
        sut.reset()
        let afterReset = sut.smooth(0.2)
        
        // Assert
        XCTAssertEqual(afterReset, 0.2) // Should return first value again
    }
    
    // MARK: - Helpers
    
    private func calculateVariance(_ values: [Float]) -> Float {
        guard !values.isEmpty else { return 0 }
        let mean = values.reduce(0, +) / Float(values.count)
        let squaredDiffs = values.map { pow($0 - mean, 2) }
        return squaredDiffs.reduce(0, +) / Float(values.count)
    }
}