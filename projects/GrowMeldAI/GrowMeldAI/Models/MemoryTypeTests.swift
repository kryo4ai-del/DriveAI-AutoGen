// Tests/Features/EpisodicMemories/Models/MemoryTypeTests.swift
import XCTest
@testable import DriveAI

final class MemoryTypeTests: XCTestCase {
    
    func testAllCasesHaveDisplayNames() {
        for type in MemoryType.allCases {
            XCTAssertFalse(type.displayName.isEmpty)
        }
    }
    
    func testAllCasesHaveIcons() {
        for type in MemoryType.allCases {
            XCTAssertFalse(type.icon.isEmpty)
        }
    }
    
    func testRawValueMapping() {
        XCTAssertEqual(MemoryType.correctAnswer.rawValue, "correct_answer")
        XCTAssertEqual(MemoryType.examPass.rawValue, "exam_pass")
    }
    
    func testInit_FromRawValue() {
        XCTAssertEqual(MemoryType(rawValue: "correct_answer"), .correctAnswer)
        XCTAssertEqual(MemoryType(rawValue: "milestone"), .milestone)
        XCTAssertNil(MemoryType(rawValue: "invalid"))
    }
}

final class EmotionalTagTests: XCTestCase {
    
    func testAllTagsHaveEmoji() {
        for tag in EmotionalTag.allCases {
            XCTAssertFalse(tag.emoji.isEmpty)
            // Verify it's actually an emoji (single grapheme cluster)
            XCTAssertEqual(tag.emoji.count, 1)
        }
    }
    
    func testAllTagsHaveDisplayNames() {
        for tag in EmotionalTag.allCases {
            XCTAssertFalse(tag.displayName.isEmpty)
        }
    }
    
    func testGermanLocalization() {
        XCTAssertEqual(EmotionalTag.proud.displayName, "Stolz")
        XCTAssertEqual(EmotionalTag.motivated.displayName, "Motiviert")
    }
}