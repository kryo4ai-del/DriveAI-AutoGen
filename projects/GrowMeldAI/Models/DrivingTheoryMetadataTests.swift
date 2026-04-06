import XCTest
@testable import DriveAI

final class DrivingTheoryMetadataTests: XCTestCase {
    
    // MARK: - Severity Classification
    
    func testSeverityDeterminesUIColor() {
        let safetyMetadata = DrivingTheoryMetadata(
            stvoSection: "StVO §3",
            trafficSignNumber: nil,
            legalExplanation: "Pedestrian crossing",
            commonMistakes: [],
            relatedTopics: [],
            severity: .safety,  // Red
            mnemonicHint: nil
        )
        
        let criticalMetadata = DrivingTheoryMetadata(
            stvoSection: "StVO §25",
            trafficSignNumber: nil,
            legalExplanation: "Right-of-way violation",
            commonMistakes: [],
            relatedTopics: [],
            severity: .critical,  // Orange
            mnemonicHint: nil
        )
        
        XCTAssertEqual(safetyMetadata.severity.color, .red)
        XCTAssertEqual(criticalMetadata.severity.color, .orange)
    }
    
    // MARK: - Mnemonic Hints
    
    func testMnemonicHintPresent() {
        let metadata = DrivingTheoryMetadata(
            stvoSection: nil,
            trafficSignNumber: "Zeichen 205",
            legalExplanation: "Geschwindigkeitsbegrenzung",
            commonMistakes: [],
            relatedTopics: [],
            severity: .standard,
            mnemonicHint: "1-0-0 außerorts, 1-3-0 Autobahn"
        )
        
        XCTAssertNotNil(metadata.mnemonicHint)
        XCTAssertTrue(metadata.mnemonicHint!.contains("1-0-0"))
    }
    
    func testMnemonicHintOptional() {
        let metadata = DrivingTheoryMetadata(
            stvoSection: nil,
            trafficSignNumber: nil,
            legalExplanation: "Test",
            commonMistakes: [],
            relatedTopics: [],
            severity: .standard,
            mnemonicHint: nil
        )
        
        XCTAssertNil(metadata.mnemonicHint)
    }
    
    // MARK: - Related Topics Cross-Reference
    
    func testRelatedTopicsArePresent() {
        let metadata = DrivingTheoryMetadata(
            stvoSection: "StVO §3",
            trafficSignNumber: nil,
            legalExplanation: "Explanation",
            commonMistakes: [],
            relatedTopics: ["Verkehrsregeln", "Sicherheit", "Bußgelder"],
            severity: .standard,
            mnemonicHint: nil
        )
        
        XCTAssertEqual(metadata.relatedTopics.count, 3)
        XCTAssertTrue(metadata.relatedTopics.contains("Verkehrsregeln"))
    }
}