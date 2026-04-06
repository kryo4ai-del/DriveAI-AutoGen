// Tests/Unit/ReminderTriggerTests.swift

import XCTest
@testable import DriveAI

final class ReminderTriggerTests: XCTestCase {
    
    // MARK: - Factory Method Tests
    
    func test_examFailed_createsCorrectTrigger() {
        let trigger = ReminderTrigger.examFailed(categoryName: "traffic-signs", score: 45)
        
        XCTAssertEqual(trigger.kind, .examFailed)
        XCTAssertEqual(trigger.categoryName, "traffic-signs")
        XCTAssertEqual(trigger.score, 45)
        XCTAssertNil(trigger.date)
        XCTAssertNil(trigger.categoryID)
    }
    
    func test_streakBroken_createsCorrectTrigger() {
        let trigger = ReminderTrigger.streakBroken
        
        XCTAssertEqual(trigger.kind, .streakBroken)
        XCTAssertNil(trigger.categoryName)
        XCTAssertNil(trigger.score)
    }
    
    func test_scheduledCheckIn_preservesDate() {
        let date = Date(timeIntervalSince1970: 1000000)
        let trigger = ReminderTrigger.scheduledCheckIn(date)
        
        XCTAssertEqual(trigger.kind, .scheduledCheckIn)
        XCTAssertEqual(trigger.date, date)
    }
    
    func test_weakAreaReview_storesCategoryID() {
        let trigger = ReminderTrigger.weakAreaReview(categoryID: "right-of-way")
        
        XCTAssertEqual(trigger.kind, .weakAreaReview)
        XCTAssertEqual(trigger.categoryID, "right-of-way")
    }
    
    // MARK: - Codable Tests
    
    func test_examFailed_encodesAndDecodes() throws {
        let original = ReminderTrigger.examFailed(categoryName: "fines", score: 60)
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ReminderTrigger.self, from: encoded)
        
        XCTAssertEqual(decoded.kind, original.kind)
        XCTAssertEqual(decoded.categoryName, original.categoryName)
        XCTAssertEqual(decoded.score, original.score)
    }
    
    func test_scheduledCheckIn_preservesDateAfterCoding() throws {
        let date = Date()
        let original = ReminderTrigger.scheduledCheckIn(date)
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ReminderTrigger.self, from: encoded)
        
        XCTAssertEqual(decoded.date?.timeIntervalSince1970 ?? 0,
                      original.date?.timeIntervalSince1970 ?? 0,
                      accuracy: 1.0) // Allow 1 second tolerance
    }
    
    func test_allTriggerTypes_encodeSuccessfully() throws {
        let triggers: [ReminderTrigger] = [
            .examFailed(categoryName: "test", score: 50),
            .streakBroken,
            .scheduledCheckIn(Date()),
            .weakAreaReview(categoryID: "test-id")
        ]
        
        for trigger in triggers {
            let encoded = try JSONEncoder().encode(trigger)
            let decoded = try JSONDecoder().decode(ReminderTrigger.self, from: encoded)
            XCTAssertEqual(decoded.kind, trigger.kind)
        }
    }
    
    // MARK: - Localization Key Tests
    
    func test_localizationKey_returnsValidString() {
        let trigger = ReminderTrigger.examFailed(categoryName: "test", score: 50)
        XCTAssertEqual(trigger.localizationKey, "reminder.trigger.examFailed")
    }
    
    func test_localizationKey_uniquePerType() {
        let keys = [
            ReminderTrigger.examFailed(categoryName: "test", score: 50).localizationKey,
            ReminderTrigger.streakBroken.localizationKey,
            ReminderTrigger.scheduledCheckIn(Date()).localizationKey,
            ReminderTrigger.weakAreaReview(categoryID: "test").localizationKey
        ]
        
        let uniqueKeys = Set(keys)
        XCTAssertEqual(uniqueKeys.count, 4)
    }
    
    // MARK: - Hashable Tests
    
    func test_sameTrigger_haveEqualHash() {
        let trigger1 = ReminderTrigger.examFailed(categoryName: "test", score: 50)
        let trigger2 = ReminderTrigger.examFailed(categoryName: "test", score: 50)
        
        XCTAssertEqual(trigger1.hashValue, trigger2.hashValue)
    }
    
    func test_differentTriggers_haveUnequalHash() {
        let trigger1 = ReminderTrigger.examFailed(categoryName: "test", score: 50)
        let trigger2 = ReminderTrigger.examFailed(categoryName: "test", score: 60)
        
        XCTAssertNotEqual(trigger1.hashValue, trigger2.hashValue)
    }
    
    // MARK: - Edge Cases
    
    func test_examFailed_withZeroScore() {
        let trigger = ReminderTrigger.examFailed(categoryName: "test", score: 0)
        XCTAssertEqual(trigger.score, 0)
    }
    
    func test_examFailed_withMaxScore() {
        let trigger = ReminderTrigger.examFailed(categoryName: "test", score: 100)
        XCTAssertEqual(trigger.score, 100)
    }
    
    func test_examFailed_withEmptyCategoryName() {
        let trigger = ReminderTrigger.examFailed(categoryName: "", score: 50)
        XCTAssertEqual(trigger.categoryName, "")
    }
    
    func test_weakAreaReview_withSpecialCharacters() {
        let categoryID = "category-with-special_chars.123"
        let trigger = ReminderTrigger.weakAreaReview(categoryID: categoryID)
        XCTAssertEqual(trigger.categoryID, categoryID)
    }
}