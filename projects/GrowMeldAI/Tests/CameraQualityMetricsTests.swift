final class CameraQualityMetricsTests: XCTestCase {
    
    func test_qualityScore_calculatesWeightedAverage() {
        let metrics = CameraQualityMetrics(
            brightness: 1.0,    // 20% = 0.2
            contrast: 1.0,      // 10% = 0.1
            focus: 1.0,         // 40% = 0.4
            alignment: 1.0      // 30% = 0.3
        )
        
        let expectedScore: Float = 0.2 + 0.1 + 0.4 + 0.3  // = 1.0
        XCTAssertEqual(metrics.qualityScore, expectedScore, accuracy: 0.01)
    }
    
    func test_qualityScore_isAcceptable_whenGreaterThan0_65() {
        let metrics = CameraQualityMetrics(
            brightness: 0.8,
            contrast: 0.7,
            focus: 0.7,
            alignment: 0.65
        )
        
        let score = metrics.qualityScore
        if score >= 0.65 {
            XCTAssertTrue(metrics.isAcceptable)
        }
    }
    
    func test_qualityScore_isNotAcceptable_whenLessThan0_65() {
        let metrics = CameraQualityMetrics(
            brightness: 0.3,
            contrast: 0.2,
            focus: 0.4,
            alignment: 0.3
        )
        
        XCTAssertFalse(metrics.isAcceptable)
    }
    
    func test_feedback_isExcellent_forHighScores() {
        let metrics = CameraQualityMetrics(
            brightness: 0.95,
            contrast: 0.9,
            focus: 0.95,
            alignment: 0.95
        )
        
        XCTAssertTrue(metrics.feedback.contains("✅"))
        XCTAssertTrue(metrics.feedback.contains("Ausgezeichnet"))
    }
    
    func test_feedback_isPoor_forLowScores() {
        let metrics = CameraQualityMetrics(
            brightness: 0.2,
            contrast: 0.1,
            focus: 0.2,
            alignment: 0.1
        )
        
        XCTAssertTrue(metrics.feedback.contains("❌"))
    }
    
    func test_codableConformance_encodesDecode() throws {
        let original = CameraQualityMetrics(
            brightness: 0.8,
            contrast: 0.7,
            focus: 0.75,
            alignment: 0.85
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CameraQualityMetrics.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
}