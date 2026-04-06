// MARK: - Tests/Services/RegionRepositoryTests.swift

final class RegionRepositoryTests: XCTestCase {
    
    var repository: RegionRepository!
    var mockDataService: MockLocalDataService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        repository = RegionRepository(localDataService: mockDataService)
    }
    
    // HAPPY PATH
    func test_LoadAustraliaRegions_Success() async throws {
        // Arrange
        let australiaCountry = Country.australia
        mockDataService.regionsToReturn = [
            MockDataFactory.nsw,
            MockDataFactory.victoria
        ]
        
        // Act
        let regions = try await repository.regions(for: australiaCountry)
        
        // Assert
        XCTAssertEqual(regions.count, 2)
        XCTAssertEqual(regions[0].id, "NSW")
        XCTAssertEqual(regions[1].id, "VIC")
        XCTAssertTrue(regions.allSatisfy { $0.isoCode.starts(with: "AU") })
    }
    
    func test_LoadCanadaRegions_Success() async throws {
        // Arrange
        let canadaCountry = Country.canada
        mockDataService.regionsToReturn = [
            MockDataFactory.ontario
        ]
        
        // Act
        let regions = try await repository.regions(for: canadaCountry)
        
        // Assert
        XCTAssertEqual(regions.count, 1)
        XCTAssertEqual(regions[0].name, "Ontario")
        XCTAssertTrue(regions.allSatisfy { $0.isoCode.starts(with: "CA") })
    }
    
    func test_RegionsCached_AfterFirstLoad() async throws {
        // Arrange
        let country = Country.australia
        mockDataService.regionsToReturn = [MockDataFactory.nsw]
        mockDataService.callCount = 0
        
        // Act
        _ = try await repository.regions(for: country)
        let secondCall = try await repository.regions(for: country)
        
        // Assert
        XCTAssertEqual(mockDataService.callCount, 1, "DataService called only once (cached)")
        XCTAssertEqual(secondCall.count, 1)
    }
    
    func test_RegionData_ContainsAllRequiredFields() async throws {
        // Arrange
        let country = Country.australia
        mockDataService.regionsToReturn = [MockDataFactory.nsw]
        
        // Act
        let regions = try await repository.regions(for: country)
        let region = regions[0]
        
        // Assert
        XCTAssertFalse(region.id.isEmpty)
        XCTAssertFalse(region.name.isEmpty)
        XCTAssertFalse(region.isoCode.isEmpty)
        XCTAssertGreaterThan(region.questionCount, 0)
        XCTAssertGreaterThan(region.minPassScore, 0)
        XCTAssertLessThanOrEqual(region.minPassScore, 100)
    }
}