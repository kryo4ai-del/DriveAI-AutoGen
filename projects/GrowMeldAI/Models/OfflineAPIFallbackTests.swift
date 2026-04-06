// Tests/OfflineAPIFallbackTests.swift
@MainActor
final class OfflineAPIFallbackTests: XCTestCase {
    var sut: QuestionAPIFallback!
    var mockAPI: MockQuestionAPIService!
    var mockCache: MockLocalDataService!
    var mockNetwork: MockNetworkMonitor!
    
    override func setUp() {
        super.setUp()
        mockAPI = MockQuestionAPIService()
        mockCache = MockLocalDataService()
        mockNetwork = MockNetworkMonitor()
        sut = QuestionAPIFallback(
            apiService: mockAPI,
            localCache: mockCache,
            networkMonitor: mockNetwork
        )
    }
    
    // Online + API success
    func testFetchOnlineSuccess() async throws {
        mockNetwork.isConnected = true
        let questions = MockData.sampleQuestions
        mockAPI.mockResult = .success(questions)
        
        let result = try await sut.fetchWithFallback()
        
        XCTAssertEqual(result.count, questions.count)
        XCTAssertTrue(mockCache.saveWasCalled)
    }
    
    // Online + API fails → fallback to cache
    func testFetchOnlineFailedFallbackToCache() async throws {
        mockNetwork.isConnected = true
        mockAPI.mockResult = .failure(NSError(domain: "network", code: -1))
        mockCache.mockQuestions = MockData.sampleQuestions
        
        let result = try await sut.fetchWithFallback()
        
        XCTAssertEqual(result.count, MockData.sampleQuestions.count)
    }
    
    // Offline + cache available
    func testFetchOfflineWithCache() async throws {
        mockNetwork.isConnected = false
        mockCache.mockQuestions = MockData.sampleQuestions
        
        let result = try await sut.fetchWithFallback()
        
        XCTAssertFalse(mockAPI.fetchWasCalled) // API should not be called
        XCTAssertEqual(result.count, MockData.sampleQuestions.count)
    }
    
    // Offline + no cache → clear error
    func testFetchOfflineNoCacheThrows() async {
        mockNetwork.isConnected = false
        mockCache.mockQuestions = nil
        
        do {
            _ = try await sut.fetchWithFallback()
            XCTFail("Should throw APIError.offlineNoCacheAvailable")
        } catch let error as APIError {
            XCTAssertEqual(error, .offlineNoCacheAvailable)
        }
    }
}