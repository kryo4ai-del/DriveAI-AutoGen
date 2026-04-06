import XCTest
@testable import DriveAI

@MainActor
final class RegionManagerTests: XCTestCase {
    
    var sut: RegionManager!
    var mockDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        // Use in-memory UserDefaults for tests
        let suiteName = "com.driveai.test.\(UUID().uuidString)"
        mockDefaults = UserDefaults(suiteName: suiteName)!
        
        sut = RegionManager(initialRegion: .dach, userDefaults: mockDefaults)
    }
    
    override func tearDown() {
        super.tearDown()
        mockDefaults.removePersistentDomain(forName: mockDefaults.suiteName ?? "")
    }
    
    // MARK: - Happy Path Tests
    
    func test_init_loadsPersistedRegion() {
        // Given: A saved region in UserDefaults
        mockDefaults.set("au_victoria", forKey: "app.selectedRegion")
        
        // When: Creating a new RegionManager
        let manager = RegionManager(initialRegion: .dach, userDefaults: mockDefaults)
        
        // Then: It should load the persisted region
        XCTAssertEqual(manager.currentRegion, .au_victoria)
    }
    
    func test_init_usesDefaultRegionWhenNothingSaved() {
        // Given: Empty UserDefaults
        let emptyDefaults = UserDefaults(suiteName: UUID().uuidString)!
        
        // When: Creating RegionManager with default
        let manager = RegionManager(initialRegion: .ca_ontario, userDefaults: emptyDefaults)
        
        // Then: Should use provided default
        XCTAssertEqual(manager.currentRegion, .ca_ontario)
    }
    
    func test_init_loadsMetadataForCurrentRegion() {
        // When: RegionManager initializes
        // Then: Metadata should be loaded synchronously
        XCTAssertNotNil(sut.regionMetadata)
        XCTAssertEqual(sut.regionMetadata?.region, .dach)
        XCTAssertGreaterThan(sut.regionMetadata?.questionCount ?? 0, 0)
    }
    
    func test_init_loadsConfigForCurrentRegion() {
        // When: RegionManager initializes
        // Then: Config should be loaded
        XCTAssertNotNil(sut.regionConfig)
        XCTAssertEqual(sut.regionConfig?.region, .dach)
    }
    
    func test_switchRegion_updatesCurrentRegion() async {
        // Given: RegionManager with DACH
        XCTAssertEqual(sut.currentRegion, .dach)
        
        // When: Switching to Victoria
        await sut.switchRegion(.au_victoria)
        
        // Then: Current region should update
        XCTAssertEqual(sut.currentRegion, .au_victoria)
    }
    
    func test_switchRegion_persistsToUserDefaults() async {
        // Given: RegionManager
        // When: Switching regions
        await sut.switchRegion(.ca_ontario)
        
        // Then: Should persist to UserDefaults
        let saved = mockDefaults.string(forKey: "app.selectedRegion")
        XCTAssertEqual(saved, "ca_ontario")
    }
    
    func test_switchRegion_updateMetadataForNewRegion() async {
        // Given: Manager with DACH metadata
        let dachQuestionCount = sut.regionMetadata?.questionCount ?? 0
        
        // When: Switch to AU
        await sut.switchRegion(.au_victoria)
        
        // Then: Metadata should update
        XCTAssertEqual(sut.regionMetadata?.region, .au_victoria)
        // AU and DACH have different question counts
        XCTAssertNotEqual(sut.regionMetadata?.questionCount, dachQuestionCount)
    }
    
    func test_switchRegion_updateConfigForNewRegion() async {
        // When: Switching regions
        await sut.switchRegion(.ca_ontario)
        
        // Then: Config should update
        XCTAssertEqual(sut.regionConfig?.region, .ca_ontario)
    }
    
    // MARK: - Edge Cases
    
    func test_switchRegion_idempotent() async {
        // Given: Current region is DACH
        XCTAssertEqual(sut.currentRegion, .dach)
        
        // When: Switching to same region multiple times
        await sut.switchRegion(.dach)
        await sut.switchRegion(.dach)
        
        // Then: Should remain DACH (no unnecessary persists)
        XCTAssertEqual(sut.currentRegion, .dach)
    }
    
    func test_switchRegion_rapidSequence() async {
        // When: Rapidly switching regions
        await sut.switchRegion(.au_victoria)
        await sut.switchRegion(.ca_ontario)
        await sut.switchRegion(.dach)
        
        // Then: Final region should be DACH
        XCTAssertEqual(sut.currentRegion, .dach)
        
        // And: UserDefaults should reflect final state
        let saved = mockDefaults.string(forKey: "app.selectedRegion")
        XCTAssertEqual(saved, "dach")
    }
    
    func test_metadata_matchesRegion() {
        // When: Checking metadata for each region
        for region in Region.allCases {
            let manager = RegionManager(initialRegion: region, userDefaults: mockDefaults)
            
            // Then: Metadata region should match current region
            XCTAssertEqual(manager.regionMetadata?.region, region)
        }
    }
    
    func test_examDateValidation_passingScorePerRegion() {
        // Each region has region-specific passing score
        let dachMetadata = RegionMetadata.metadata(for: .dach)
        let auMetadata = RegionMetadata.metadata(for: .au_victoria)
        let caMetadata = RegionMetadata.metadata(for: .ca_ontario)
        
        // DACH: 75%, AU/CA: 80%
        XCTAssertEqual(dachMetadata.passingScore, 75)
        XCTAssertEqual(auMetadata.passingScore, 80)
        XCTAssertEqual(caMetadata.passingScore, 80)
    }
}