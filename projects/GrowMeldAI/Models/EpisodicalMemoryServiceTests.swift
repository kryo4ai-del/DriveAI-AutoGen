// Tests/EpisodicalMemoryServiceTests.swift
@MainActor
final class EpisodicalMemoryServiceTests: XCTestCase {
    var sut: EpisodicalMemoryService!
    var tempDir: URL!
    
    override func setUp() async throws {
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        sut = EpisodicalMemoryService()
    }
    
    func testAddAndLoadMemory() async throws {
        let memory = EpisodicalMemory(
            questionCategoryId: "test",
            questionId: "q1",
            userAnswer: "A",
            correctAnswer: "B",
            isCorrect: false,
            emotionalTag: .confusion
        )
        
        await sut.addMemory(memory)
        XCTAssertEqual(sut.memories.count, 1)
        
        let fresh = EpisodicalMemoryService()
        await fresh.loadMemories()
        XCTAssertEqual(fresh.memories.count, 1)
        XCTAssertEqual(fresh.memories.first?.emotionalTag, .confusion)
    }
}