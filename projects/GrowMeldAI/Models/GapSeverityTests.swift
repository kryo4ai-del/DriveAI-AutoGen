// MARK: - Tests/Domain/Models/GapSeverityTests.swift

import XCTest
@testable import DriveAI

final class GapSeverityTests: XCTestCase {
    
    // MARK: - Comparable Tests
    
    func test_comparison_criticalGreaterThanModerate() {
        XCTAssertGreaterThan(GapSeverity.critical, .moderate)
    }
    
    func test_comparison_moderateGreaterThanMinor() {
        XCTAssertGreaterThan(GapSeverity.moderate, .minor)
    }
    
    func test_sorting_bySeverity() {
        let gaps: [GapSeverity] = [.minor, .critical, .moderate]
        let sorted = gaps.sorted(by: >)  // Descending
        XCTAssertEqual(sorted, [.critical, .moderate, .minor])
    }
    
    // MARK: - Hashable Tests
    
    func test_canBeStoredInSet() {
        let severity: Set<GapSeverity> = [.critical, .moderate, .minor]
        XCTAssertEqual(severity.count, 3)
    }
    
    func test_canBeUsedAsDictionaryKey() {
        let counts: [GapSeverity: Int] = [
            .critical: 2,
            .moderate: 3,
            .minor: 1
        ]
        XCTAssertEqual(counts[.critical], 2)
    }
    
    // MARK: - Properties Tests
    
    func test_critical_hasRedColor() {
        XCTAssertEqual(GapSeverity.critical.color, .red)
    }
    
    func test_allSeverities_haveIcons() {
        XCTAssertFalse(GapSeverity.critical.icon.isEmpty)
        XCTAssertFalse(GapSeverity.moderate.icon.isEmpty)
        XCTAssertFalse(GapSeverity.minor.icon.isEmpty)
    }
}