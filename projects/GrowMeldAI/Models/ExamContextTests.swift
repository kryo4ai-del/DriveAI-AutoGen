@MainActor
final class ExamContextTests: XCTestCase {
    
    func testContextInitialization() {
        let region = PostalCodeRegion.mock(
            trafficLevel: .high,
            regionalQuestionWeight: 1.5
        )
        
        let context = ExamContext(from: region)
        
        XCTAssertTrue(context.isHighTraffic)
        XCTAssertEqual(context.examFrequency.rawValue, region.examFrequencyTier.rawValue)
        XCTAssertEqual(context.regionalQuestionWeight, 1.5)
    }
    
    func testTrafficLevelColoring() {
        let lowRegion = PostalCodeRegion.mock(trafficLevel: .low)
        let mediumRegion = PostalCodeRegion.mock(trafficLevel: .medium)
        let highRegion = PostalCodeRegion.mock(trafficLevel: .high)
        
        let lowContext = ExamContext(from: lowRegion)
        let mediumContext = ExamContext(from: mediumRegion)
        let highContext = ExamContext(from: highRegion)
        
        XCTAssertEqual(lowContext.trafficLevelColor, "#10B981")
        XCTAssertEqual(mediumContext.trafficLevelColor, "#F59E0B")
        XCTAssertEqual(highContext.trafficLevelColor, "#EF4444")
    }
    
    func testCommonMistakesInheritance() {
        let region = PostalCodeRegion.mock(
            commonMistakes: ["Fehler1", "Fehler2", "Fehler3"]
        )
        let context = ExamContext(from: region)
        
        XCTAssertEqual(context.commonMistakes.count, 3)
        XCTAssertEqual(context.commonMistakes, region.commonMistakes)
    }
}