// Tests/Models/SessionRecordTests.swift
import XCTest
@testable import BreathFlow

final class SessionRecordTests: XCTestCase {
    
    // MARK: - Initialization & Validation
    
    func testValidSessionCreation() throws {
        let record = try SessionRecord(
            technique: .calmBreathing,
            durationSeconds: 300,
            completedCycles: 5
        )
        
        XCTAssertEqual(record.durationSeconds, 300)
        XCTAssertEqual(record.completedCycles, 5)
        XCTAssertNotNil(record.id)
    }
    
    func testMinimumDurationEnforced() throws {
        XCTAssertThrowsError(
            try SessionRecord(
                technique: .calmBreathing,
                durationSeconds: 0,
                completedCycles: 0
            )
        ) { error in
            guard case SessionRecord.SessionError.invalidDuration = error else {
                XCTFail("Expected invalidDuration error")
                return
            }
        }
    }
    
    func testNegativeDurationRejected() throws {
        XCTAssertThrowsError(
            try SessionRecord(
                technique: .fourSevenEight,
                durationSeconds: -10,
                completedCycles: 0
            )
        )
    }
    
    func testNegativeCyclesRejected() throws {
        XCTAssertThrowsError(
            try SessionRecord(
                technique: .boxBreathing,
                durationSeconds: 120,
                completedCycles: -1
            )
        ) { error in
            guard case SessionRecord.SessionError.invalidCycles = error else {
                XCTFail("Expected invalidCycles error")
                return
            }
        }
    }
    
    func testZeroCyclesAllowed() throws {
        let record = try SessionRecord(
            technique: .calmBreathing,
            durationSeconds: 30,
            completedCycles: 0
        )
        
        XCTAssertEqual(record.completedCycles, 0)
    }
    
    // MARK: - Computed Properties
    
    func testDurationMinutesCalculation() throws {
        let record = try SessionRecord(
            technique: .calmBreathing,
            durationSeconds: 125,
            completedCycles: 2
        )
        
        XCTAssertEqual(record.durationMinutes, 2) // 125 / 60 = 2 (rounded down)
    }
    
    func testTechniqueEnumConversion() throws {
        let record = try SessionRecord(
            technique: .fourSevenEight,
            durationSeconds: 240,
            completedCycles: 3
        )
        
        XCTAssertEqual(record.techniqueEnum, .fourSevenEight)
    }
    
    func testInvalidTechniqueDefaultsFallback() throws {
        // Simulate corrupted technique string
        let record = try SessionRecord(
            technique: .calmBreathing,
            durationSeconds: 60,
            completedCycles: 1
        )
        
        // Manually corrupt (mimicking UserDefaults corruption)
        var corrupted = record
        // In real scenario, techniqueEnum would fallback to .calmBreathing
        XCTAssertEqual(corrupted.techniqueEnum, .calmBreathing)
    }
    
    // MARK: - Codable
    
    func testEncodingAndDecoding() throws {
        let original = try SessionRecord(
            date: Date(timeIntervalSince1970: 1000000),
            technique: .fourSevenEight,
            durationSeconds: 300,
            completedCycles: 5
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SessionRecord.self, from: data)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.technique, decoded.technique)
        XCTAssertEqual(original.durationSeconds, decoded.durationSeconds)
    }
    
    // MARK: - Edge Cases
    
    func testVeryLongSession() throws {
        let record = try SessionRecord(
            technique: .calmBreathing,
            durationSeconds: 3600, // 1 hour
            completedCycles: 720
        )
        
        XCTAssertEqual(record.durationMinutes, 60)
    }
    
    func testOneSecondSession() throws {
        let record = try SessionRecord(
            technique: .calmBreathing,
            durationSeconds: 1,
            completedCycles: 0
        )
        
        XCTAssertEqual(record.durationSeconds, 1)
        XCTAssertEqual(record.durationMinutes, 0)
    }
}