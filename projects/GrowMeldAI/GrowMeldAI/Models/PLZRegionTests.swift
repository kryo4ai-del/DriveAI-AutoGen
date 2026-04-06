import XCTest
@testable import DriveAI

final class PLZRegionTests: XCTestCase {
    
    // MARK: - PLZ Validation
    
    func test_contains_validPLZInRange() {
        let region = PLZRegion.allRegions.first { $0.id == "BY" }!
        
        XCTAssertTrue(region.contains(plz: "80001"))   // Munich
        XCTAssertTrue(region.contains(plz: "80999"))   // Munich
        XCTAssertTrue(region.contains(plz: "97999"))   // Upper range
    }
    
    func test_contains_validPLZWithLeadingZeros() {
        let region = PLZRegion.allRegions.first { $0.id == "SN" }!  // Sachsen
        
        XCTAssertTrue(region.contains(plz: "01000"))   // Dresden
        XCTAssertTrue(region.contains(plz: "09999"))   // Upper range
    }
    
    func test_contains_PLZOutsideRange() {
        let bavaria = PLZRegion.allRegions.first { $0.id == "BY" }!
        let berlin = PLZRegion.allRegions.first { $0.id == "BE" }!
        
        XCTAssertFalse(bavaria.contains(plz: "10115"))  // Berlin PLZ
        XCTAssertFalse(berlin.contains(plz: "80001"))   // Bavaria PLZ
    }
    
    func test_contains_invalidFormat_tooShort() {
        let region = PLZRegion.allRegions.first { $0.id == "BY" }!
        
        XCTAssertFalse(region.contains(plz: "8001"))    // 4 digits
        XCTAssertFalse(region.contains(plz: ""))        // Empty
    }
    
    func test_contains_invalidFormat_tooLong() {
        let region = PLZRegion.allRegions.first { $0.id == "BY" }!
        
        XCTAssertFalse(region.contains(plz: "800001"))  // 6 digits
    }
    
    func test_contains_invalidFormat_nonNumeric() {
        let region = PLZRegion.allRegions.first { $0.id == "BY" }!
        
        XCTAssertFalse(region.contains(plz: "8000A"))
        XCTAssertFalse(region.contains(plz: "800-01"))
        XCTAssertFalse(region.contains(plz: "800 01"))
    }
    
    func test_contains_boundaryValues() {
        let region = PLZRegion.allRegions.first { $0.id == "BY" }!  // 80000-97999
        
        XCTAssertTrue(region.contains(plz: "80000"))    // Start boundary
        XCTAssertTrue(region.contains(plz: "97999"))    // End boundary
        XCTAssertFalse(region.contains(plz: "79999"))   // Just before start
        XCTAssertFalse(region.contains(plz: "98000"))   // Just after end
    }
    
    // MARK: - Data Integrity
    
    func test_allRegions_has16States() {
        XCTAssertEqual(PLZRegion.allRegions.count, 16)
    }
    
    func test_allRegions_uniqueIDs() {
        let ids = Set(PLZRegion.allRegions.map { $0.id })
        XCTAssertEqual(ids.count, 16, "Duplicate region IDs found")
    }
    
    func test_allRegions_nonOverlappingRanges() {
        let sorted = PLZRegion.allRegions.sorted { $0.plzRangeStart < $1.plzRangeStart }
        
        for i in 0..<(sorted.count - 1) {
            let current = sorted[i]
            let next = sorted[i + 1]
            
            XCTAssertLessThanOrEqual(
                current.plzRangeEnd, next.plzRangeStart,
                "Overlapping ranges: \(current.id) and \(next.id)"
            )
        }
    }
    
    func test_allRegions_leadingZeroes_preserved() {
        // Saxony should start with "01000", not "1000"
        let saxony = PLZRegion.allRegions.first { $0.id == "SN" }!
        XCTAssertEqual(saxony.plzRangeStart, "01000")
        XCTAssertTrue(saxony.contains(plz: "01234"))
    }
    
    func test_displayName_returnsLocalized() {
        let region = PLZRegion.allRegions.first { $0.id == "BY" }!
        XCTAssertEqual(region.displayName, "Bayern")
    }
    
    // MARK: - Codable
    
    func test_codable_encodeDecode() throws {
        let region = PLZRegion.allRegions.first { $0.id == "BE" }!
        
        let encoded = try JSONEncoder().encode(region)
        let decoded = try JSONDecoder().decode(PLZRegion.self, from: encoded)
        
        XCTAssertEqual(region, decoded)
    }
    
    // MARK: - Hashable & Equatable
    
    func test_hashable_sameIDHashesEqual() {
        let region1 = PLZRegion.allRegions.first { $0.id == "BY" }!
        let region2 = PLZRegion.allRegions.first { $0.id == "BY" }!
        
        XCTAssertEqual(region1.hashValue, region2.hashValue)
    }
    
    func test_equatable_sameIDEquals() {
        let region1 = PLZRegion.allRegions.first { $0.id == "BY" }!
        let region2 = PLZRegion.allRegions.first { $0.id == "BY" }!
        
        XCTAssertEqual(region1, region2)
    }
    
    func test_set_deduplication() {
        let regions = [
            PLZRegion.allRegions.first { $0.id == "BY" }!,
            PLZRegion.allRegions.first { $0.id == "BY" }!,  // Duplicate ID
            PLZRegion.allRegions.first { $0.id == "BE" }!,
        ]
        
        let set = Set(regions)
        XCTAssertEqual(set.count, 2, "Set should deduplicate by ID")
    }
}