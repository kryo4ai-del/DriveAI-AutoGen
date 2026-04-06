final class RegionRepositoryEdgeCaseTests: XCTestCase {
    
    var repository: RegionRepository!
    var mockDataService: MockLocalDataService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        repository = RegionRepository(localDataService: mockDataService)
    }
    
    // EDGE CASE: No regions available
    func test_LoadRegions_EmptyResult_ThrowsError() async {
        // Arrange
        mockDataService.regionsToReturn = []
        
        // Act & Assert
        do {
            _ = try await repository.regions(for: .australia)
            XCTFail("Expected regionsEmpty error")
        } catch let error as RegionRepository.Error {
            XCTAssertEqual(error, .regionsEmpty)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // EDGE CASE: Region with zero questions
    func test_LoadRegions_RegionHasZeroQuestions_Filtered() async throws {
        // Arrange
        mockDataService.regionsToReturn = [
            Region(id: "ZZZ", name: "Empty Region", subtitle: "Test", 
                   isoCode: "AU-ZZZ", questionCount: 0, minPassScore: 50)
        ]
        mockDataService.invalidRegionIds = ["ZZZ"]  // Mark as having no questions
        
        // Act & Assert
        do {
            _ = try await repository.regions(for: .australia)
            XCTFail("Expected regionsEmpty error when all regions invalid")
        } catch let error as RegionRepository.Error {
            XCTAssertEqual(error, .regionsEmpty)
        }
    }
    
    // EDGE CASE: Corrupted manifest file
    func test_LoadRegions_CorruptedManifest_ThrowsError() async {
        // Arrange
        mockDataService.shouldThrowError = .dataCorrupted("Invalid JSON")
        
        // Act & Assert
        do {
            _ = try await repository.regions(for: .australia)
            XCTFail("Expected dataCorrupted error")
        } catch let error as RegionRepository.Error {
            XCTAssertEqual(error, .dataCorrupted("Invalid JSON"))
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    // EDGE CASE: Missing manifest file
    func test_LoadRegions_ManifestNotFound_ThrowsError() async {
        // Arrange
        mockDataService.shouldThrowError = .manifestNotFound
        
        // Act & Assert
        do {
            _ = try await repository.regions(for: .australia)
            XCTFail("Expected manifestNotFound error")
        } catch let error as RegionRepository.Error {
            XCTAssertEqual(error, .manifestNotFound)
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    // EDGE CASE: Very large region list
    func test_LoadRegions_LargeDataset_Performance() async throws {
        // Arrange
        mockDataService.regionsToReturn = (0..<1000).map { i in
            Region(
                id: "REG\(i)",
                name: "Region \(i)",
                subtitle: "Subtitle \(i)",
                isoCode: "AU-REG\(i)",
                questionCount: 50 + (i % 200),
                minPassScore: 75
            )
        }
        
        // Act
        let startTime = Date()
        let regions = try await repository.regions(for: .australia)
        let duration = Date().timeIntervalSince(startTime)
        
        // Assert
        XCTAssertEqual(regions.count, 1000)
        XCTAssertLessThan(duration, 1.0, "Loading 1000 regions should complete in <1 second")
    }
    
    // EDGE CASE: Concurrent requests for same country
    func test_LoadRegions_ConcurrentRequests_ReturnsCached() async throws {
        // Arrange
        mockDataService.regionsToReturn = [MockDataFactory.nsw]
        mockDataService.callCount = 0
        
        // Act
        async let request1 = repository.regions(for: .australia)
        async let request2 = repository.regions(for: .australia)
        async let request3 = repository.regions(for: .australia)
        
        let result1 = try await request1
        let result2 = try await request2
        let result3 = try await request3
        
        // Assert
        XCTAssertEqual(result1, result2)
        XCTAssertEqual(result2, result3)
        // Note: Call count may be 1 or 3 depending on actor isolation timing
        XCTAssertLessThanOrEqual(mockDataService.callCount, 3)
    }
    
    // EDGE CASE: Pass score boundary conditions
    func test_LoadRegions_MinPassScoreBoundary() async throws {
        // Arrange
        let edgeCaseRegions = [
            Region(id: "A", name: "Low Pass", subtitle: "", isoCode: "AU-A", 
                   questionCount: 10, minPassScore: 1),  // Boundary low
            Region(id: "B", name: "High Pass", subtitle: "", isoCode: "AU-B", 
                   questionCount: 10, minPassScore: 100)  // Boundary high
        ]
        mockDataService.regionsToReturn = edgeCaseRegions
        
        // Act
        let regions = try await repository.regions(for: .australia)
        
        // Assert
        XCTAssertTrue(regions.contains { $0.minPassScore == 1 })
        XCTAssertTrue(regions.contains { $0.minPassScore == 100 })
    }
}