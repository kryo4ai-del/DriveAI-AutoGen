final class CategoryReadinessCodableTests: XCTestCase {

    func test_codableRoundTrip_preservesAllValues() throws {
        let original = CategoryReadiness.make(
            categoryID: "traffic-signs",
            categoryName: "Verkehrszeichen",
            questionsTotal: 80,
            questionsAttempted: 60,
            correctAnswers: 48,
            lastAttempted: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CategoryReadiness.self, from: data)

        XCTAssertEqual(original, decoded)
        XCTAssertEqual(decoded.categoryID, "traffic-signs")
        XCTAssertEqual(decoded.accuracyRate, original.accuracyRate, accuracy: 0.0001)
    }
}