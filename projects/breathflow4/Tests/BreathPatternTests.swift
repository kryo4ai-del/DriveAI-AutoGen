import XCTest
import Foundation
@testable import BreathFlow4

final class BreathPatternTests: XCTestCase {
    
    // MARK: - Valid Initialization
    
    func test_init_validPattern_succeeds() throws {
        // Act
        let pattern = try BreathPattern(inhale: 4, hold: 4, exhale: 4)
        
        // Assert
        XCTAssertEqual(pattern.inhale, 4)
        XCTAssertEqual(pattern.hold, 4)
        XCTAssertEqual(pattern.exhale, 4)
    }
    
    func test_init_zeroHold_accepted() throws {
        // Act
        let pattern = try BreathPattern(inhale: 4, hold: 0, exhale: 4)
        
        // Assert
        XCTAssertEqual(pattern.hold, 0)
    }
    
    func test_cycleLength_calculatesCorrectly() throws {
        // Arrange
        let pattern = try BreathPattern(inhale: 4, hold: 4, exhale: 4)
        
        // Act
        let length = pattern.cycleLength
        
        // Assert
        XCTAssertEqual(length, 12)
    }
    
    // MARK: - Invalid Initialization
    
    func test_init_zeroInhale_throws() {
        // Act & Assert
        XCTAssertThrowsError(
            try BreathPattern(inhale: 0, hold: 4, exhale: 4)
        ) { error in
            XCTAssertEqual(
                error as? ExerciseError,
                .invalidBreathPattern(reason: "Inhale and exhale must be positive")
            )
        }
    }
    
    func test_init_negativeInhale_throws() {
        // Act & Assert
        XCTAssertThrowsError(
            try BreathPattern(inhale: -1, hold: 4, exhale: 4)
        )
    }
    
    func test_init_zeroExhale_throws() {
        // Act & Assert
        XCTAssertThrowsError(
            try BreathPattern(inhale: 4, hold: 4, exhale: 0)
        )
    }
    
    func test_init_unrealisticTiming_throws() {
        // Act & Assert
        XCTAssertThrowsError(
            try BreathPattern(inhale: 120, hold: 0, exhale: 4)
        ) { error in
            XCTAssertEqual(
                error as? ExerciseError,
                .invalidBreathPattern(reason: "Timing exceeds 60 seconds (unrealistic)")
            )
        }
    }
    
    func test_init_negativeHold_clampedToZero() throws {
        // Act
        let pattern = try BreathPattern(inhale: 4, hold: -5, exhale: 4)
        
        // Assert
        XCTAssertEqual(pattern.hold, 0)
    }
    
    // MARK: - Edge Cases
    
    func test_init_boundary_60seconds_accepted() throws {
        // Act & Assert
        let pattern = try BreathPattern(inhale: 60, hold: 0, exhale: 4)
        XCTAssertEqual(pattern.inhale, 60)
    }
    
    func test_init_boundary_61seconds_rejected() {
        // Act & Assert
        XCTAssertThrowsError(
            try BreathPattern(inhale: 61, hold: 0, exhale: 4)
        )
    }
    
    func test_codable_encodesDecode() throws {
        // Arrange
        let original = try BreathPattern(inhale: 4, hold: 7, exhale: 8)
        let encoder = JSONEncoder()
        
        // Act
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(BreathPattern.self, from: data)
        
        // Assert
        XCTAssertEqual(original, decoded)
    }
}