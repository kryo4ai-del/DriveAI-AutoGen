extension LocalDataServiceTests {
    // MARK: - Concurrency & Thread Safety
    
    func test_updateProgress_noDataLossUnderConcurrentUpdates() async throws {
        let categoryID = "signs"
        
        // Simulate 10 concurrent quiz completions
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    try? await self.sut.updateProgress(
                        categoryID: categoryID,
                        correctCount: 1,
                        totalCount: 1
                    )
                }
            }
            await group.waitForAll()
        }
        
        let progress = try await sut.fetchUserProgress()
        
        XCTAssertEqual(
            progress.categoryProgress[categoryID]?.totalAttempts,
            10,
            "All 10 updates should be recorded (no data loss)"
        )
    }
    
    func test_updateProgress_readConsistency() async throws {
        try await sut.updateProgress(categoryID: "signs", correctCount: 5, totalCount: 5)
        
        // Read same data 5 times concurrently
        let results = await withTaskGroup(of: UserProgress.self, returning: [UserProgress].self) { group in
            for _ in 0..<5 {
                group.addTask {
                    try! await self.sut.fetchUserProgress()
                }
            }
            
            var results: [UserProgress] = []
            for await progress in group {
                results.append(progress)
            }
            return results
        }
        
        // All reads should be identical
        let firstScore = results[0].categoryProgress["signs"]?.correctAnswers
        for result in results {
            XCTAssertEqual(
                result.categoryProgress["signs"]?.correctAnswers,
                firstScore,
                "All concurrent reads should return same data"
            )
        }
    }
}