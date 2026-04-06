import XCTest
@testable import DriveAI

final class PLZMappingServiceTests: XCTestCase {
    
    let service = PLZMappingService.shared
    
    // MARK: - Lookup Performance
    
    func test_region_O1Performance() {
        measure {
            for _ in 0..<1000 {
                _ = service.region(for: "80001")
            }
        }
        // Should complete in <50ms
    }
    
    // MARK: - Lookup Correctness
    
    func test_region_validPLZ() {
        let region = service.region(for: "80001")
        XCTAssertNotNil(region)
        XCTAssertEqual(region?.id, "BY")
    }
    
    func test_region_invalidFormat() {
        XCTAssertNil(service.region(for: "8001"))      // Too short
        XCTAssertNil(service.region(for: "800001"))    // Too long
        XCTAssertNil(service.region(for: "INVALID"))   // Non-numeric
    }
    
    func test_region_allBundeslaender() {
        let testCases: [(plz: String, expectedID: String)] = [
            ("70001", "BW"),   // Baden-Württemberg
            ("80001", "BY"),   // Bavaria
            ("10115", "BE"),   // Berlin
            ("01234", "SN"),   // Saxony (leading zero)
            ("20001", "HH"),   // Hamburg
        ]
        
        for (plz, expectedID) in testCases {
            let region = service.region(for: plz)
            XCTAssertEqual(
                region?.id, expectedID,
                "PLZ \(plz) should map to \(expectedID)"
            )
        }
    }
    
    func test_region_byID() {
        let region = service.region(byId: "BY")
        XCTAssertNotNil(region)
        XCTAssertEqual(region?.localizedName, "Bayern")
    }
    
    func test_region_byID_invalid() {
        XCTAssertNil(service.region(byId: "XX"))
    }
    
    // MARK: - Batch Operations
    
    func test_allRegions_returns16Bundeslaender() {
        let regions = service.allRegions()
        XCTAssertEqual(regions.count, 16)
    }
    
    func test_allRegions_sortedByName() {
        let regions = service.allRegions()
        let sorted = regions.sorted { $0.localizedName < $1.localizedName }
        
        XCTAssertEqual(regions.map { $0.id }, sorted.map { $0.id })
    }
    
    // MARK: - Data Validation
    
    func test_validatePLZRanges_noOverlaps() {
        let errors = service.validatePLZRanges()
        XCTAssertTrue(errors.isEmpty, "Found overlapping PLZ ranges: \(errors)")
    }
    
    // MARK: - Edge Cases
    
    func test_region_boundaryPLZs() {
        // Test every region's boundary
        for region in PLZRegion.allRegions {
            XCTAssertNotNil(
                service.region(for: region.plzRangeStart),
                "Start PLZ \(region.plzRangeStart) should resolve to \(region.id)"
            )
            XCTAssertNotNil(
                service.region(for: region.plzRangeEnd),
                "End PLZ \(region.plzRangeEnd) should resolve to \(region.id)"
            )
        }
    }
}