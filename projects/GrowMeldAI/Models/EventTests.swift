import XCTest
@testable import DriveAI

final class EventTests: XCTestCase {
    
    var sessionID: UUID!
    
    override func setUp() {
        super.setUp()
        sessionID = UUID()
    }
    
    // MARK: - Happy Path Tests
    
    func testDomainEventCreation() {
        let payload = EventPayload(["categoryID": "signs", "count": 10])
        
        let event = DomainEvent(
            type: .quizStarted,
            sessionID: sessionID,
            payload: payload
        )
        
        XCTAssertEqual(event.eventType, .quizStarted)
        XCTAssertEqual(event.sessionID, sessionID)
        XCTAssertNotNil(event.id)
        XCTAssertNotNil(event.timestamp)
    }
    
    func testDomainEventWithoutPayload() {
        let event = DomainEvent(
            type: .appLaunched,
            sessionID: sessionID
        )
        
        XCTAssertTrue(event.payload.isEmpty)
        XCTAssertEqual(event.eventType, .appLaunched)
    }
    
    func testDomainEventWithCustomTimestamp() {
        let customDate = Date(timeIntervalSince1970: 0)
        let event = DomainEvent(
            type: .questionAnswered,
            sessionID: sessionID,
            payload: EventPayload(["isCorrect": true]),
            timestamp: customDate
        )
        
        XCTAssertEqual(event.timestamp, customDate)
    }
    
    // MARK: - EventPayload Type-Safe Accessors
    
    func testEventPayloadGetInt() {
        let payload = EventPayload(["score": 85, "count": 10])
        
        XCTAssertEqual(payload.getInt("score"), 85)
        XCTAssertEqual(payload.getInt("count"), 10)
        XCTAssertNil(payload.getInt("nonexistent"))
    }
    
    func testEventPayloadGetString() {
        let payload = EventPayload(["category": "traffic_signs", "name": "Test Quiz"])
        
        XCTAssertEqual(payload.getString("category"), "traffic_signs")
        XCTAssertEqual(payload.getString("name"), "Test Quiz")
        XCTAssertNil(payload.getString("nonexistent"))
    }
    
    func testEventPayloadGetDouble() {
        let payload = EventPayload(["accuracy": 92.5, "timeSpent": 15.3])
        
        XCTAssertEqual(payload.getDouble("accuracy"), 92.5)
        XCTAssertEqual(payload.getDouble("timeSpent"), 15.3)
        XCTAssertNil(payload.getDouble("nonexistent"))
    }
    
    func testEventPayloadGetBool() {
        let payload = EventPayload(["passed": true, "completed": false])
        
        XCTAssertEqual(payload.getBool("passed"), true)
        XCTAssertEqual(payload.getBool("completed"), false)
        XCTAssertNil(payload.getBool("nonexistent"))
    }
    
    func testEventPayloadGetDate() {
        let date = Date()
        let payload = EventPayload(["timestamp": date])
        
        XCTAssertEqual(payload.getDate("timestamp"), date)
        XCTAssertNil(payload.getDate("nonexistent"))
    }
    
    func testEventPayloadGetUUID() {
        let uuid = UUID()
        let payload = EventPayload(["userID": uuid.uuidString])
        
        XCTAssertEqual(payload.getUUID("userID"), uuid)
        XCTAssertNil(payload.getUUID("invalid"))
        XCTAssertNil(payload.getUUID("nonexistent"))
    }
    
    func testEventPayloadGetDictionary() {
        let innerDict: [String: Any] = ["key1": "value1", "key2": 42]
        let payload = EventPayload(["nested": innerDict])
        
        let retrieved = payload.getDictionary("nested")
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?["key1"] as? String, "value1")
        XCTAssertEqual(retrieved?["key2"] as? Int, 42)
    }
    
    func testEventPayloadGetArray() {
        let payload = EventPayload(["numbers": [1, 2, 3, 4, 5]])
        
        let ints = payload.getArray("numbers", type: Int.self)
        XCTAssertEqual(ints, [1, 2, 3, 4, 5])
        
        XCTAssertNil(payload.getArray("nonexistent", type: Int.self))
    }
    
    // MARK: - EventPayload Mutations
    
    func testEventPayloadSetting() {
        var payload = EventPayload(["initial": "value"])
        payload = payload.setting("score", to: 95)
        payload = payload.setting("passed", to: true)
        
        XCTAssertEqual(payload.getString("initial"), "value")
        XCTAssertEqual(payload.getInt("score"), 95)
        XCTAssertEqual(payload.getBool("passed"), true)
    }
    
    func testEventPayloadRemoving() {
        let payload = EventPayload(["key1": "value1", "key2": "value2", "key3": "value3"])
        let updated = payload.removing("key2")
        
        XCTAssertEqual(updated.getString("key1"), "value1")
        XCTAssertNil(updated.getString("key2"))
        XCTAssertEqual(updated.getString("key3"), "value3")
    }
    
    func testEventPayloadSubscript() {
        let payload = EventPayload(["score": 85])
        
        XCTAssertEqual(payload["score"] as? Int, 85)
        XCTAssertNil(payload["nonexistent"])
    }
    
    func testEventPayloadAllKeys() {
        let payload = EventPayload(["a": 1, "b": "two", "c": 3.0])
        
        let keys = Set(payload.allKeys)
        XCTAssertEqual(keys, ["a", "b", "c"])
    }
    
    func testEventPayloadEmpty() {
        let payload = EventPayload()
        
        XCTAssertTrue(payload.isEmpty)
        XCTAssertEqual(payload.allKeys.count, 0)
    }
    
    // MARK: - AnyCodable Type Erasure
    
    func testAnyCodableWithBool() {
        let codable = AnyCodable(true)
        XCTAssertEqual(codable.value as? Bool, true)
    }
    
    func testAnyCodableWithInt() {
        let codable = AnyCodable(42)
        XCTAssertEqual(codable.value as? Int, 42)
    }
    
    func testAnyCodableWithDouble() {
        let codable = AnyCodable(3.14)
        XCTAssertEqual(codable.value as? Double, 3.14)
    }
    
    func testAnyCodableWithString() {
        let codable = AnyCodable("test")
        XCTAssertEqual(codable.value as? String, "test")
    }
    
    func testAnyCodableWithUUID() {
        let uuid = UUID()
        let codable = AnyCodable(uuid)
        XCTAssertEqual(codable.value as? UUID, uuid)
    }
    
    func testAnyCodableWithDate() {
        let date = Date()
        let codable = AnyCodable(date)
        XCTAssertEqual(codable.value as? Date, date)
    }
    
    func testAnyCodableWithNull() {
        let codable = AnyCodable(NSNull())
        XCTAssert(codable.value is NSNull)
    }
    
    // MARK: - Codable Conformance
    
    func testDomainEventEncoding() throws {
        let payload = EventPayload(["score": 85.5, "passed": true])
        let event = DomainEvent(
            type: .examSimulationCompleted,
            sessionID: sessionID,
            payload: payload
        )
        
        let encoded = try JSONEncoder().encode(event)
        XCTAssertFalse(encoded.isEmpty)
    }
    
    func testDomainEventDecoding() throws {
        let original = DomainEvent(
            type: .quizCompleted,
            sessionID: sessionID,
            payload: EventPayload(["quizID": "quiz-123", "score": 90])
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DomainEvent.self, from: encoded)
        
        XCTAssertEqual(decoded.eventType, original.eventType)
        XCTAssertEqual(decoded.sessionID, original.sessionID)
        XCTAssertEqual(decoded.payload.getString("quizID"), "quiz-123")
        XCTAssertEqual(decoded.payload.getInt("score"), 90)
    }
    
    func testEventPayloadEncoding() throws {
        let payload = EventPayload([
            "int": 42,
            "string": "test",
            "double": 3.14,
            "bool": true
        ])
        
        let encoded = try JSONEncoder().encode(payload)
        let decoded = try JSONDecoder().decode(EventPayload.self, from: encoded)
        
        XCTAssertEqual(decoded.getInt("int"), 42)
        XCTAssertEqual(decoded.getString("string"), "test")
        XCTAssertEqual(decoded.getDouble("double"), 3.14)
        XCTAssertEqual(decoded.getBool("bool"), true)
    }
    
    func testAnyCodableEncoding() throws {
        let codables: [AnyCodable] = [
            AnyCodable(42),
            AnyCodable("test"),
            AnyCodable(3.14),
            AnyCodable(true),
            AnyCodable(Date())
        ]
        
        for codable in codables {
            let encoded = try JSONEncoder().encode(codable)
            let decoded = try JSONDecoder().decode(AnyCodable.self, from: encoded)
            XCTAssertEqual(codable, decoded)
        }
    }
    
    // MARK: - Edge Cases
    
    func testEventPayloadWithEmptyString() {
        let payload = EventPayload(["empty": ""])
        XCTAssertEqual(payload.getString("empty"), "")
    }
    
    func testEventPayloadWithZeroValues() {
        let payload = EventPayload(["zero_int": 0, "zero_double": 0.0])
        XCTAssertEqual(payload.getInt("zero_int"), 0)
        XCTAssertEqual(payload.getDouble("zero_double"), 0.0)
    }
    
    func testEventPayloadWithNegativeValues() {
        let payload = EventPayload(["negative_int": -42, "negative_double": -3.14])
        XCTAssertEqual(payload.getInt("negative_int"), -42)
        XCTAssertEqual(payload.getDouble("negative_double"), -3.14)
    }
    
    func testEventPayloadWithVeryLargeNumbers() {
        let largeInt = Int.max
        let largeDouble = Double.greatestFiniteMagnitude
        let payload = EventPayload(["large_int": largeInt, "large_double": largeDouble])
        
        XCTAssertEqual(payload.getInt("large_int"), largeInt)
        XCTAssertEqual(payload.getDouble("large_double"), largeDouble)
    }
    
    func testEventPayloadWithSpecialCharacters() {
        let special = "!@#$%^&*()_+-=[]{}|;:',.<>?/~`"
        let payload = EventPayload(["special": special])
        XCTAssertEqual(payload.getString("special"), special)
    }
    
    func testEventPayloadWithUnicodeCharacters() {
        let unicode = "こんにちは 🚗 Ñoño"
        let payload = EventPayload(["unicode": unicode])
        XCTAssertEqual(payload.getString("unicode"), unicode)
    }
    
    func testEventPayloadWithNestedStructures() {
        let nested: [String: Any] = [
            "level1": [
                "level2": [
                    "level3": "deep value"
                ]
            ]
        ]
        let payload = EventPayload(nested)
        
        let retrieved = payload.getDictionary("level1")
        XCTAssertNotNil(retrieved)
    }
    
    // MARK: - Type Mismatch Tests
    
    func testEventPayloadTypeMismatchReturnsNil() {
        let payload = EventPayload(["string_value": "not_a_number"])
        
        XCTAssertNil(payload.getInt("string_value"))
        XCTAssertNil(payload.getDouble("string_value"))
        XCTAssertNil(payload.getBool("string_value"))
    }
    
    func testEventPayloadInvalidUUIDStringReturnsNil() {
        let payload = EventPayload(["invalid_uuid": "not-a-valid-uuid"])
        XCTAssertNil(payload.getUUID("invalid_uuid"))
    }
    
    // MARK: - Equatable Tests
    
    func testAnyCodableEquality() {
        let codable1 = AnyCodable(42)
        let codable2 = AnyCodable(42)
        let codable3 = AnyCodable(43)
        
        XCTAssertEqual(codable1, codable2)
        XCTAssertNotEqual(codable1, codable3)
    }
    
    func testEventPayloadEquality() {
        let payload1 = EventPayload(["key": "value", "number": 42])
        let payload2 = EventPayload(["key": "value", "number": 42])
        let payload3 = EventPayload(["key": "other"])
        
        XCTAssertEqual(payload1, payload2)
        XCTAssertNotEqual(payload1, payload3)
    }
    
    // MARK: - Identifiable Conformance
    
    func testDomainEventIdentifiable() {
        let event1 = DomainEvent(type: .appLaunched, sessionID: sessionID)
        let event2 = DomainEvent(type: .appLaunched, sessionID: sessionID)
        
        XCTAssertNotEqual(event1.id, event2.id)
    }
}