import XCTest
@testable import DriveAI

final class AnxietyLevelTests: XCTestCase {

    // MARK: - Completeness

    func test_allCases_hasFiveLevels() {
        XCTAssertEqual(AnxietyLevel.allCases.count, 5)
    }

    func test_allCases_rawValues_areContiguous_oneToFive() {
        let rawValues = AnxietyLevel.allCases.map(\.rawValue).sorted()
        XCTAssertEqual(rawValues, [1, 2, 3, 4, 5])
    }

    func test_allCases_haveNonEmptyLabels() {
        for level in AnxietyLevel.allCases {
            XCTAssertFalse(level.label.isEmpty, "Label empty for \(level)")
        }
    }

    func test_allCases_haveNonEmptySymbolNames() {
        for level in AnxietyLevel.allCases {
            XCTAssertFalse(level.symbolName.isEmpty, "Symbol empty for \(level)")
        }
    }

    func test_allCases_haveNonEmptyColorTokens() {
        for level in AnxietyLevel.allCases {
            XCTAssertFalse(level.colorToken.isEmpty, "Color token empty for \(level)")
        }
    }

    // MARK: - Identity

    func test_id_equalsRawValue() {
        for level in AnxietyLevel.allCases {
            XCTAssertEqual(level.id, level.rawValue)
        }
    }

    func test_allCases_haveUniqueIDs() {
        let ids = AnxietyLevel.allCases.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    // MARK: - Label uniqueness

    func test_allCases_haveUniqueLabels() {
        let labels = AnxietyLevel.allCases.map(\.label)
        XCTAssertEqual(labels.count, Set(labels).count)
    }

    // MARK: - Codable

    func test_codable_roundTrip_allCases() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for level in AnxietyLevel.allCases {
            let data = try encoder.encode(level)
            let decoded = try decoder.decode(AnxietyLevel.self, from: data)
            XCTAssertEqual(decoded, level)
        }
    }

    func test_codable_decodesFromRawValue() throws {
        // Ensures stable on-disk representation
        let data = try JSONEncoder().encode(3)
        let decoded = try JSONDecoder().decode(AnxietyLevel.self, from: data)
        XCTAssertEqual(decoded, .neutral)
    }

    func test_codable_invalidRawValue_throws() {
        let data = Data("99".utf8)
        XCTAssertThrowsError(
            try JSONDecoder().decode(AnxietyLevel.self, from: data)
        )
    }

    // MARK: - Specific values

    func test_veryCalm_rawValue_isOne() {
        XCTAssertEqual(AnxietyLevel.veryCalm.rawValue, 1)
    }

    func test_veryAnxious_rawValue_isFive() {
        XCTAssertEqual(AnxietyLevel.veryAnxious.rawValue, 5)
    }
}