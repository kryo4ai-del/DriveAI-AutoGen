// MARK: - Tests/BuildPhaseTests.swift

final class BundleResourceTests: XCTestCase {
    func testRegionManifestsExist() {
        // Verify all required manifest files are bundled
        let countries = ["au", "ca"]
        
        for country in countries {
            let filename = "regions-\(country).json"
            let url = Bundle.main.url(forResource: filename, withExtension: nil)
            XCTAssertNotNil(
                url,
                "Missing required bundle resource: \(filename)"
            )
        }
    }
    
    func testRegionManifestsAreValid() throws {
        // Verify JSON is parseable and has correct structure
        let countries = ["au", "ca"]
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        for country in countries {
            let filename = "regions-\(country).json"
            guard let url = Bundle.main.url(forResource: filename, withExtension: nil),
                  let data = try? Data(contentsOf: url) else {
                XCTFail("Cannot load \(filename)")
                return
            }
            
            do {
                let manifest = try decoder.decode(RegionManifest.self, from: data)
                XCTAssertFalse(manifest.regions.isEmpty, "\(filename) has no regions")
                XCTAssertEqual(manifest.countryId.uppercased(), country.uppercased())
            } catch {
                XCTFail("\(filename) is invalid JSON: \(error)")
            }
        }
    }
}