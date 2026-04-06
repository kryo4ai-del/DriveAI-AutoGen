import Foundation

#if canImport(XCTest)
import XCTest

class ConsentDecisionTests: XCTestCase {}

extension ConsentDecisionTests {

    func testDecode_missingTimestamp_throwsDecodingError() throws {
        let json = """
        {
            "userConsented": true,
            "version": 1
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        XCTAssertThrowsError(
            try decoder.decode(ConsentDecision.self, from: json.data(using: .utf8)!)
        ) { error in
            guard error is DecodingError else {
                XCTFail("Expected DecodingError, got \(type(of: error))")
                return
            }
        }
    }

    func testDecode_invalidDateFormat_throwsError() throws {
        let json = """
        {
            "userConsented": true,
            "timestamp": "not-a-date",
            "version": 1
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        XCTAssertThrowsError(
            try decoder.decode(ConsentDecision.self, from: json.data(using: .utf8)!)
        )
    }

    func testDecode_futureVersion_decodesButHandled() throws {
        let json = """
        {
            "userConsented": true,
            "timestamp": "2024-01-15T10:30:00Z",
            "version": 99
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let decision = try decoder.decode(
            ConsentDecision.self,
            from: json.data(using: .utf8)!
        )

        XCTAssertEqual(decision.version, 99)
    }
}

#endif