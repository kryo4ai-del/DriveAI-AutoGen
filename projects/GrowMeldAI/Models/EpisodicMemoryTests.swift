// Tests/Features/EpisodicMemories/Models/EpisodicMemoryTests.swift
import XCTest
@testable import DriveAI

final class EpisodicMemoryTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func testInit_WithAllParameters_CreatesValidMemory() {
        let id = UUID()
        let timestamp = Date()
        let emotionalTag = EmotionalTag.proud
        
        let memory = EpisodicMemory(
            id: id,
            timestamp: timestamp,
            type: .correctAnswer,
            questionID: "q123",
            categoryID: "cat_signs",
            categoryName: "Verkehrszeichen",
            emotionalTag: emotionalTag,
            reflection: "Learned this easily",
            synapsStrength: 75
        )
        
        XCTAssertEqual(memory.id, id)
        XCTAssertEqual(memory.timestamp, timestamp)
        XCTAssertEqual(memory.type, .correctAnswer)
        XCTAssertEqual(memory.emotionalTag, emotionalTag)
        XCTAssertEqual(memory.synapsStrength, 75)
        XCTAssertFalse(memory.isArchived)
    }
    
    func testInit_WithDefaults_CreatesMemoryWithValidDefaults() {
        let memory = EpisodicMemory(
            type: .milestone,
            questionID: "q456",
            categoryID: "cat_rightofway",
            categoryName: "Vorfahrtsregeln"
        )
        
        XCTAssertEqual(memory.type, .milestone)
        XCTAssertEqual(memory.synapsStrength, 50)  // Default
        XCTAssertNil(memory.emotionalTag)
        XCTAssertFalse(memory.isPrivate)
        XCTAssertFalse(memory.isArchived)
    }
    
    func testStub_ProducesValidTestFixture() {
        let stub = EpisodicMemory.stub()
        
        XCTAssertNotNil(stub.id)
        XCTAssertEqual(stub.type, .correctAnswer)
        XCTAssertEqual(stub.categoryID, "cat_signs")
        XCTAssertTrue(Calendar.current.isDateInToday(stub.timestamp))
    }
    
    // MARK: - Edge Cases
    
    func testInit_WithZeroSynapsStrength_Accepts() {
        let memory = EpisodicMemory(
            type: .attempted,
            questionID: "q789",
            categoryID: "cat_test",
            categoryName: "Test",
            synapsStrength: 0
        )
        XCTAssertEqual(memory.synapsStrength, 0)
    }
    
    func testInit_With100SynapsStrength_Accepts() {
        let memory = EpisodicMemory(
            type: .examPass,
            questionID: "q999",
            categoryID: "cat_test",
            categoryName: "Test",
            synapsStrength: 100
        )
        XCTAssertEqual(memory.synapsStrength, 100)
    }
    
    func testInit_WithEmptyReflectionString_Accepts() {
        let memory = EpisodicMemory(
            type: .correctAnswer,
            questionID: "q111",
            categoryID: "cat_test",
            categoryName: "Test",
            reflection: ""
        )
        XCTAssertEqual(memory.reflection, "")
    }
    
    // MARK: - Codable Conformance
    
    func testEncode_WithCompleteData_ProducesValidJSON() throws {
        let memory = EpisodicMemory(
            type: .streakReached,
            questionID: "q222",
            categoryID: "cat_test",
            categoryName: "Test Category",
            emotionalTag: .motivated,
            reflection: "Great progress!"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(memory)
        
        XCTAssertGreaterThan(data.count, 0)
    }
    
    func testDecode_WithValidJSON_ProducesMemory() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "timestamp": "2026-04-02T10:30:00Z",
            "type": "correct_answer",
            "questionID": "q333",
            "categoryID": "cat_signs",
            "categoryName": "Verkehrszeichen",
            "emotionalTag": "confident",
            "reflection": "Got it!",
            "synapsStrength": 80,
            "isPrivate": false,
            "isArchived": false,
            "createdAt": "2026-04-02T10:30:00Z",
            "updatedAt": "2026-04-02T10:30:00Z"
        }
        """
        
        let decoder = JSONDecoder()
        let memory = try decoder.decode(
            EpisodicMemory.self,
            from: json.data(using: .utf8)!
        )
        
        XCTAssertEqual(memory.questionID, "q333")
        XCTAssertEqual(memory.emotionalTag, .confident)
    }
    
    // MARK: - Hashable Conformance
    
    func testHash_WithSameID_ProducesEqualHash() {
        let id = UUID()
        let memory1 = EpisodicMemory(
            id: id,
            type: .correctAnswer,
            questionID: "q444",
            categoryID: "cat1",
            categoryName: "Cat1"
        )
        let memory2 = EpisodicMemory(
            id: id,
            type: .milestone,
            questionID: "q445",
            categoryID: "cat2",
            categoryName: "Cat2"
        )
        
        XCTAssertEqual(memory1, memory2)  // Same ID
    }
}