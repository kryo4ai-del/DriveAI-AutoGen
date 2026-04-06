// Tests/Unit/ReminderPreferencesTests.swift

import XCTest
@testable import DriveAI

final class ReminderPreferencesTests: XCTestCase {
    
    // MARK: - Default Initialization
    
    func test_defaultPreferences_hasExpectedValues() {
        let prefs = ReminderPreferences()
        
        XCTAssertTrue(prefs.isEnabled)
        XCTAssertFalse(prefs.allowNotifications)
        XCTAssertEqual(prefs.maxRemindersPerDay, 1)
        XCTAssertEqual(prefs.preferredHour, 18)
        XCTAssertTrue(prefs.optedInCategories.isEmpty)
    }
    
    // MARK: - Codable Tests
    
    func test_preferences_encodeAndDecode() throws {
        var prefs = ReminderPreferences()
        prefs.allowNotifications = true
        prefs.maxRemindersPerDay = 3
        prefs.preferredHour = 20
        prefs.optedInCategories = ["traffic-signs", "fines"]
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(prefs)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ReminderPreferences.self, from: encoded)
        
        XCTAssertEqual(decoded.allowNotifications, true)
        XCTAssertEqual(decoded.maxRemindersPerDay, 3)
        XCTAssertEqual(decoded.preferredHour, 20)
        XCTAssertEqual(decoded.optedInCategories, ["traffic-signs", "fines"])
    }
    
    func test_preferences_preservesEmptyCategories() throws {
        var prefs = ReminderPreferences()
        prefs.optedInCategories = []
        
        let encoded = try JSONEncoder().encode(prefs)
        let decoded = try JSONDecoder().decode(ReminderPreferences.self, from: encoded)
        
        XCTAssertTrue(decoded.optedInCategories.isEmpty)
    }
    
    // MARK: - Property Mutations
    
    func test_preferences_canDisable() {
        var prefs = ReminderPreferences()
        prefs.isEnabled = false
        XCTAssertFalse(prefs.isEnabled)
    }
    
    func test_preferences_maxRemindersPerDay_canChange() {
        var prefs = ReminderPreferences()
        prefs.maxRemindersPerDay = 5
        XCTAssertEqual(prefs.maxRemindersPerDay, 5)
    }
    
    func test_preferences_preferredHour_canChange() {
        var prefs = ReminderPreferences()
        prefs.preferredHour = 9
        XCTAssertEqual(prefs.preferredHour, 9)
    }
    
    func test_preferences_optedInCategories_canBeAdded() {
        var prefs = ReminderPreferences()
        prefs.optedInCategories = ["traffic-signs"]
        XCTAssertTrue(prefs.optedInCategories.contains("traffic-signs"))
    }
    
    // MARK: - Equatable Tests
    
    func test_identicalPreferences_areEqual() {
        let prefs1 = ReminderPreferences()
        let prefs2 = ReminderPreferences()
        XCTAssertEqual(prefs1, prefs2)
    }
    
    func test_differentPreferences_areNotEqual() {
        var prefs1 = ReminderPreferences()
        var prefs2 = ReminderPreferences()
        
        prefs2.allowNotifications = true
        XCTAssertNotEqual(prefs1, prefs2)
    }
    
    // MARK: - Edge Cases
    
    func test_preferredHour_minimumValue() {
        var prefs = ReminderPreferences()
        prefs.preferredHour = 0
        XCTAssertEqual(prefs.preferredHour, 0)
    }
    
    func test_preferredHour_maximumValue() {
        var prefs = ReminderPreferences()
        prefs.preferredHour = 23
        XCTAssertEqual(prefs.preferredHour, 23)
    }
    
    func test_maxRemindersPerDay_largeValue() {
        var prefs = ReminderPreferences()
        prefs.maxRemindersPerDay = 100
        XCTAssertEqual(prefs.maxRemindersPerDay, 100)
    }
    
    func test_optedInCategories_manyCategories() {
        var prefs = ReminderPreferences()
        let categories = (0..<50).map { "category-\($0)" }
        prefs.optedInCategories = categories
        XCTAssertEqual(prefs.optedInCategories.count, 50)
    }
}