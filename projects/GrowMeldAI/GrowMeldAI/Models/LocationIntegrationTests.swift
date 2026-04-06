final class LocationIntegrationTests: XCTestCase {
    func testBundleDataLoadAndQuery() async throws {
        let tempDB = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("test_regions.db")
        
        try? FileManager.default.removeItem(at: tempDB)
        
        let database = try RegionDatabase(path: tempDB.path)
        try await LocationDataLoader.loadBundledRegions(into: database)
        
        // Verify data was loaded
        let region = try await database.getRegion(plz: "10115")
        XCTAssertNotNil(region)
        XCTAssertEqual(region?.name, "Berlin Mitte")
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempDB)
    }
}