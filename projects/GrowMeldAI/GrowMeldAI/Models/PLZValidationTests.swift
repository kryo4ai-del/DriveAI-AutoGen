import XCTest
@testable import DriveAI

final class PLZValidationTests: XCTestCase {
    
    func test_isValidGermanPLZ_validFormats() {
        XCTAssertTrue("10115".isValidGermanPLZ)   // Berlin
        XCTAssertTrue("80001".isValidGermanPLZ)   // Munich
        XCTAssertTrue("01234".isValidGermanPLZ)   // Leading zero
        XCTAssertTrue("00000".isValidGermanPLZ)   // All zeros (technically valid format)
        XCTAssertTrue("99999".isValidGermanPLZ)   // Max
    }
    
    func test_isValidGermanPLZ_invalidFormats() {
        XCTAssertFalse("1011".isValidGermanPLZ)      // 4 digits
        XCTAssertFalse("101151".isValidGermanPLZ)    // 6 digits
        XCTAssertFalse("".isValidGermanPLZ)          // Empty
        XCTAssertFalse("1011A".isValidGermanPLZ)     // Non-numeric
        XCTAssertFalse("101-15".isValidGermanPLZ)    // Special char
        XCTAssertFalse("101 15".isValidGermanPLZ)    // Space
    }
}