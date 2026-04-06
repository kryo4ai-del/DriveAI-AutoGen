// Concrete, repeatable diagnostics
class LocalDataServiceDiagnostics {
  
  func verifySchemaIntegrity() throws {
    let columns = try db.execute(
      "PRAGMA table_info(questions)"
    )
    XCTAssertTrue(columns.contains { $0.name == "id" })
    XCTAssertTrue(columns.contains { $0.name == "category_id" })
    XCTAssertTrue(columns.contains { $0.name == "image_path" })
  }
  
  func verifyImageAssetCoverage() throws {
    let missingImages = try db.execute("""
      SELECT id FROM questions WHERE image_path IS NOT NULL
      EXCEPT SELECT DISTINCT question_id FROM images
    """)
    XCTAssertEqual(missingImages.count, 0, 
      "Found questions with missing image assets")
  }
  
  func verifyCategoryDistribution() throws {
    let expected: [String: Int] = ["traffic_signs": 300, "right_of_way": 250]
    let actual = try db.execute(
      "SELECT category, COUNT(*) FROM questions GROUP BY category"
    )
    for (category, expectedCount) in expected {
      XCTAssertEqual(actual[category], expectedCount)
    }
  }
}