class AppErrorTests: XCTestCase {
    
    func testErrorDescription() {
        let loadingError = AppError.loadingFailed("Network timeout")
        XCTAssertEqual(loadingError.errorDescription, "Failed to load: Network timeout")
        
        let decodingError = AppError.decodingFailed
        XCTAssertEqual(decodingError.errorDescription, "Unable to parse exercise data")
        
        let notFoundError = AppError.notFound
        XCTAssertEqual(notFoundError.errorDescription, "Exercise not found")
    }
    
    func testErrorRecoverySuggestion() {
        let loadingError = AppError.loadingFailed("timeout")
        XCTAssertNotNil(loadingError.recoverySuggestion)
        XCTAssertTrue(loadingError.recoverySuggestion!.contains("internet"))
    }
    
    func testErrorIdentifiable() {
        let error = AppError.loadingFailed("test")
        XCTAssertNotNil(error.id)
    }
}