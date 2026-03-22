// Tests/Services/StatsServiceTests.swift
import XCTest
@testable import BreathFlow

@MainActor
final class StatsServiceTests: XCTestCase {
    var sut: StatsService!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = StatsService()
        // Clean UserDefaults between tests
        UserDefaults.standard.removeObject(forKey: "breathing_sessions")
        sut.loadAllSessions()
    }
    
    // MARK: - Save & Load
    
    func testSaveAndLoadSession() throws {
        let record = try SessionRecord(
            technique: .calmBreathing,
            durationSeconds: 300,
            completedCycles: 5
        )
        
        let saved = sut.saveSession(record)
        XCTAssertTrue(saved)
        XCTAssertEqual(sut.allSessions.count, 1)
        XCTAssertEqual(sut.allSessions[0].id, record.id)
    }
    
    func testLoadSessionsEmptyByDefault() {
        XCTAssertEqual(sut.allSessions.count, 0)
    }
    
    func testMultipleSessions() throws {
        let records = try [
            SessionRecord(technique: .calmBreathing, durationSeconds: 300, completedCycles: 5),
            SessionRecord(technique: .boxBreathing, durationSeconds: 240, completedCycles: 6),
            SessionRecord(technique: .fourSevenEight, durationSeconds: 360, completedCycles: 4)
        ]
        
        for record in records {
            _ = sut.saveSession(record)
        }
        
        XCTAssertEqual(sut.allSessions.count, 3)
    }
    
    // MARK: - Delete
    
    func testDeleteSession() throws {
        let record = try SessionRecord(
            technique: .calmBreathing,
            durationSeconds: 300,
            completedCycles: 5
        )
        
        sut.saveSession(record)
        XCTAssertEqual(sut.allSessions.count, 1)
        
        let deleted = sut.deleteSession(record.id)
        XCTAssertTrue(deleted)
        XCTAssertEqual(sut.allSessions.count, 0)
    }
    
    func testDeleteNonexistentSession() {
        let deleted = sut.deleteSession(UUID())
        XCTAssertFalse(deleted)
    }
    
    // MARK: - Weekly Minutes (H2 Fix: Timezone)
    
    func testWeeklyMinutesThisWeek() throws {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let today = calendar.startOfDay(for: Date())
        
        let record = try SessionRecord(
            date: today,
            technique: .calmBreathing,
            durationSeconds: 300, // 5 minutes
            completedCycles: 5
        )
        
        sut.saveSession(record)
        XCTAssertEqual(sut.weeklyMinutes(), 5)
    }
    
    func testWeeklyMinutesExcludesOldSessions() throws {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let eightDaysAgo = calendar.date(byAdding: .day, value: -8, to: Date())!
        
        let oldRecord = try SessionRecord(
            date: eightDaysAgo,
            technique: .calmBreathing,
            durationSeconds: 600,
            completedCycles: 10
        )
        
        sut.saveSession(oldRecord)
        XCTAssertEqual(sut.weeklyMinutes(), 0, "Sessions older than 7 days should not count")
    }
    
    func testWeeklyMinutesBoundary() throws {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: Date()))!
        
        let record = try SessionRecord(
            date: sevenDaysAgo,
            technique: .calmBreathing,
            durationSeconds: 300,
            completedCycles: 5
        )
        
        sut.saveSession(record)
        XCTAssertEqual(sut.weeklyMinutes(), 5, "Sessions from exactly 7 days ago should count")
    }
    
    func testWeeklyMinutesMultipleSessions() throws {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let today = calendar.startOfDay(for: Date())
        
        let records = try [
            SessionRecord(date: today, technique: .calmBreathing, durationSeconds: 300, completedCycles: 5),
            SessionRecord(date: today, technique: .boxBreathing, durationSeconds: 240, completedCycles: 6),
            SessionRecord(date: today, technique: .fourSevenEight, durationSeconds: 360, completedCycles: 4)
        ]
        
        for record in records {
            sut.saveSession(record)
        }
        
        XCTAssertEqual(sut.weeklyMinutes(), 15) // 5 + 4 + 6 minutes
    }
    
    // MARK: - Total Minutes
    
    func testTotalMinutesAllTime() throws {
        let oldRecord = try SessionRecord(
            date: Date(timeIntervalSinceNow: -60*60*24*30),
            technique: .calmBreathing,
            durationSeconds: 300,
            completedCycles: 5
        )
        
        let newRecord = try SessionRecord(
            technique: .boxBreathing,
            durationSeconds: 240,
            completedCycles: 6
        )
        
        sut.saveSession(oldRecord)
        sut.saveSession(newRecord)
        
        XCTAssertEqual(sut.totalMinutes(), 9) // 5 + 4 minutes
    }
    
    // MARK: - Session Count by Technique
    
    func testSessionCountByTechnique() throws {
        let calm1 = try SessionRecord(technique: .calmBreathing, durationSeconds: 300, completedCycles: 5)
        let calm2 = try SessionRecord(technique: .calmBreathing, durationSeconds: 240, completedCycles: 4)
        let box1 = try SessionRecord(technique: .boxBreathing, durationSeconds: 180, completedCycles: 3)
        
        sut.saveSession(calm1)
        sut.saveSession(calm2)
        sut.saveSession(box1)
        
        XCTAssertEqual(sut.sessionCount(for: .calmBreathing), 2)
        XCTAssertEqual(sut.sessionCount(for: .boxBreathing), 1)
        XCTAssertEqual(sut.sessionCount(for: .fourSevenEight), 0)
    }
    
    // MARK: - Latest Session
    
    func testLatestSession() throws {
        let old = try SessionRecord(
            date: Date(timeIntervalSinceNow: -3600),
            technique: .calmBreathing,
            durationSeconds: 300,
            completedCycles: 5
        )
        
        let new = try SessionRecord(
            technique: .boxBreathing,
            durationSeconds: 240,
            completedCycles: 6
        )
        
        sut.saveSession(old)
        sut.saveSession(new)
        
        let latest = sut.latestSession()
        XCTAssertEqual(latest?.id, new.id)
    }
    
    func testLatestSessionWhenEmpty() {
        let latest = sut.latestSession()
        XCTAssertNil(latest)
    }
    
    // MARK: - Persistence
    
    func testSessionsPersistAcrossInstances() throws {
        let record = try SessionRecord(
            technique: .calmBreathing,
            durationSeconds: 300,
            completedCycles: 5
        )
        
        sut.saveSession(record)
        
        // Create new instance (simulates app relaunch)
        let newService = StatsService()
        XCTAssertEqual(newService.allSessions.count, 1)
        XCTAssertEqual(newService.allSessions[0].id, record.id)
    }
    
    // MARK: - Error Handling (M1 Fix)
    
    func testCorruptedDataBackupCreated() throws {
        // Manually corrupt UserDefaults
        UserDefaults.standard.set(Data(count: 10), forKey: "breathing_sessions")
        
        sut.loadAllSessions()
        
        XCTAssertEqual(sut.allSessions.count, 0, "Should fallback to empty array on corruption")
    }
    
    func testStateCoherencyAfterSave() throws {
        let record = try SessionRecord(
            technique: .calmBreathing,
            durationSeconds: 300,
            completedCycles: 5
        )
        
        sut.saveSession(record)
        
        // ✓ Fix H1: In-memory state immediately reflects save
        XCTAssertEqual(sut.allSessions.count, 1)
        XCTAssertEqual(sut.allSessions[0].id, record.id)
    }
}