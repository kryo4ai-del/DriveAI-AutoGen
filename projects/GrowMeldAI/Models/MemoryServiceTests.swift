class MemoryServiceTests: XCTestCase {
    var sut: MemoryService!
    var mockRepository: MockMemoryRepository!
    
    override func setUp() {
        mockRepository = MockMemoryRepository()
        sut = MemoryService(repository: mockRepository)
    }
    
    func testRecordMemory_WithValidData_Succeeds() async {
        let memory = EpisodicMemory.stub()
        try? await sut.recordMemory(memory)
        
        XCTAssertEqual(mockRepository.insertCalled, true)
    }
    
    func testGetTimeline_ReturnsOrderedByDate() async throws {
        let memories = try await sut.getTimelineForWeek(Date())
        
        for i in 0..<memories.count - 1 {
            XCTAssertGreaterThanOrEqual(memories[i].timestamp, memories[i + 1].timestamp)
        }
    }
}