import XCTest
@testable import DriveAI

final class RegionTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func testRegion_ValidInitialization() {
        let region = Region(
            id: "DE_Berlin",
            code: "DE_Berlin",
            name: "Berlin",
            country: "DE",
            countryName: "Deutschland",
            questionCatalogVersion: "2024_v1",
            examRules: ExamRules(
                minPassScore: 21,
                totalQuestions: 30,
                timeMinutes: 45,
                passingPercentage: 70
            )
        )
        
        XCTAssertEqual(region.name, "Berlin")
        XCTAssertEqual(region.country, "DE")
        XCTAssertTrue(region.isSupported)
    }
    
    func testRegion_DisplayLabel_FormattedCorrectly() {
        let region = Region.mockBerlin
        XCTAssertEqual(region.displayLabel, "Berlin (DE)")
    }
    
    // MARK: - MVP Support Check
    
    func testRegion_GermanySupported() {
        let regionDE = Region(
            id: "DE_Berlin", code: "DE_Berlin", name: "Berlin",
            country: "DE", countryName: "Deutschland",
            questionCatalogVersion: "2024_v1", examRules: nil
        )
        
        XCTAssertTrue(regionDE.isSupported)
    }
    
    func testRegion_AustriaNotSupported() {
        let regionAT = Region(
            id: "AT_Wien", code: "AT_Wien", name: "Wien",
            country: "AT", countryName: "Österreich",
            questionCatalogVersion: "2024_v1", examRules: nil
        )
        
        XCTAssertFalse(regionAT.isSupported)
    }
    
    func testRegion_SwitzerlandNotSupported() {
        let regionCH = Region(
            id: "CH_Zurich", code: "CH_Zurich", name: "Zürich",
            country: "CH", countryName: "Schweiz",
            questionCatalogVersion: "2024_v1", examRules: nil
        )
        
        XCTAssertFalse(regionCH.isSupported)
    }
    
    // MARK: - Exam Rules
    
    func testExamRules_ValidScores() {
        let rules = ExamRules(
            minPassScore: 21,
            totalQuestions: 30,
            timeMinutes: 45,
            passingPercentage: 70
        )
        
        XCTAssertEqual(rules.minPassScore, 21)
        XCTAssertEqual(rules.passingPercentage, 70)
    }
    
    // MARK: - Hashable & Equatable
    
    func testRegion_Equatable_SameCodeIsEqual() {
        let region1 = Region.mockBerlin
        let region2 = Region.mockBerlin
        
        XCTAssertEqual(region1, region2)
    }
    
    func testRegion_Hashable_ConsistentHash() {
        let regions = [Region.mockBerlin, Region.mockBayern]
        let set = Set(regions)
        
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - Sendable Conformance
    
    func testRegion_Sendable_CompileCheck() {
        func acceptsSendable<T: Sendable>(_: T) {}
        
        let region = Region.mockBerlin
        acceptsSendable(region)  // ✅ Should compile
    }
    
    // MARK: - Codable
    
    func testRegion_JSONDecoding_Success() throws {
        let jsonData = """
        {
            "id": "DE_Berlin",
            "code": "DE_Berlin",
            "name": "Berlin",
            "country": "DE",
            "countryName": "Deutschland",
            "questionCatalogVersion": "2024_v1",
            "examRules": {
                "minPassScore": 21,
                "totalQuestions": 30,
                "timeMinutes": 45,
                "passingPercentage": 70
            }
        }
        """.data(using: .utf8)!
        
        let region = try JSONDecoder().decode(Region.self, from: jsonData)
        
        XCTAssertEqual(region.name, "Berlin")
        XCTAssertEqual(region.examRules?.minPassScore, 21)
    }
}