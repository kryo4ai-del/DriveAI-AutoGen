import XCTest
@testable import DriveAI

final class DACHCountryTests: XCTestCase {
    
    // MARK: - Basic Properties
    
    func test_code_matches_rawValue() {
        XCTAssertEqual(DACHCountry.de.code, "DE")
        XCTAssertEqual(DACHCountry.at.code, "AT")
        XCTAssertEqual(DACHCountry.ch.code, "CH")
    }
    
    func test_displayName_german() {
        XCTAssertEqual(DACHCountry.de.displayName, "Deutschland")
        XCTAssertEqual(DACHCountry.at.displayName, "Österreich")
        XCTAssertEqual(DACHCountry.ch.displayName, "Schweiz")
    }
    
    // MARK: - PLZ Format Validation
    
    func test_isValidPLZFormat_germany_validFormat() {
        XCTAssertTrue(DACHCountry.de.isValidPLZFormat("10115"))
        XCTAssertTrue(DACHCountry.de.isValidPLZFormat("80331"))
        XCTAssertTrue(DACHCountry.de.isValidPLZFormat("50667"))
    }
    
    func test_isValidPLZFormat_germany_invalidFormat_tooShort() {
        XCTAssertFalse(DACHCountry.de.isValidPLZFormat("1011"))
    }
    
    func test_isValidPLZFormat_germany_invalidFormat_tooLong() {
        XCTAssertFalse(DACHCountry.de.isValidPLZFormat("101151"))
    }
    
    func test_isValidPLZFormat_germany_invalidFormat_letters() {
        XCTAssertFalse(DACHCountry.de.isValidPLZFormat("1011A"))
    }
    
    func test_isValidPLZFormat_germany_invalidFormat_empty() {
        XCTAssertFalse(DACHCountry.de.isValidPLZFormat(""))
    }
    
    func test_isValidPLZFormat_germany_invalidFormat_whitespaceOnly() {
        XCTAssertFalse(DACHCountry.de.isValidPLZFormat("   "))
    }
    
    func test_isValidPLZFormat_austria_validFormat() {
        XCTAssertTrue(DACHCountry.at.isValidPLZFormat("1010"))
        XCTAssertTrue(DACHCountry.at.isValidPLZFormat("6020"))
    }
    
    func test_isValidPLZFormat_austria_invalidFormat_tooLong() {
        XCTAssertFalse(DACHCountry.at.isValidPLZFormat("10101"))
    }
    
    func test_isValidPLZFormat_switzerland_validFormat() {
        XCTAssertTrue(DACHCountry.ch.isValidPLZFormat("8000"))
        XCTAssertTrue(DACHCountry.ch.isValidPLZFormat("1201"))
    }
    
    func test_isValidPLZFormat_switzerland_invalidFormat() {
        XCTAssertFalse(DACHCountry.ch.isValidPLZFormat("80001"))
    }
    
    // MARK: - PLZ Normalization
    
    func test_normalizeInputPLZ_removesSpaces() {
        let normalized = DACHCountry.de.normalizeInputPLZ("101 15")
        XCTAssertEqual(normalized, "10115")
    }
    
    func test_normalizeInputPLZ_removesHyphens() {
        let normalized = DACHCountry.de.normalizeInputPLZ("101-15")
        XCTAssertEqual(normalized, "10115")
    }
    
    func test_normalizeInputPLZ_removesLetters() {
        let normalized = DACHCountry.de.normalizeInputPLZ("101a15")
        XCTAssertEqual(normalized, "10115")
    }
    
    func test_normalizeInputPLZ_empty() {
        let normalized = DACHCountry.de.normalizeInputPLZ("")
        XCTAssertEqual(normalized, "")
    }
    
    // MARK: - Expected Length
    
    func test_expectedPLZLength_germany() {
        XCTAssertEqual(DACHCountry.de.expectedPLZLength, 5)
    }
    
    func test_expectedPLZLength_austria() {
        XCTAssertEqual(DACHCountry.at.expectedPLZLength, 4)
    }
    
    func test_expectedPLZLength_switzerland() {
        XCTAssertEqual(DACHCountry.ch.expectedPLZLength, 4)
    }
    
    // MARK: - Federal States
    
    func test_federalStates_germany() {
        let states = DACHCountry.de.federalStates
        
        XCTAssertGreaterThanOrEqual(states.count, 16)
        XCTAssertTrue(states.contains(.de_berlin))
        XCTAssertTrue(states.contains(.de_bavaria))
    }
    
    func test_federalStates_austria() {
        let states = DACHCountry.at.federalStates
        
        XCTAssertGreaterThanOrEqual(states.count, 9)
        XCTAssertTrue(states.contains(.at_vienna))
    }
    
    func test_federalStates_switzerland() {
        let states = DACHCountry.ch.federalStates
        
        XCTAssertGreaterThanOrEqual(states.count, 26)
        XCTAssertTrue(states.contains(.ch_zurich))
    }
    
    // MARK: - Codable
    
    func test_codable_encode() throws {
        let country = DACHCountry.de
        let data = try JSONEncoder().encode(country)
        
        let json = try JSONSerialization.jsonObject(with: data)
        XCTAssertEqual(json as? String, "DE")
    }
    
    func test_codable_decode() throws {
        let json = "\"AT\"".data(using: .utf8)!
        let country = try JSONDecoder().decode(DACHCountry.self, from: json)
        
        XCTAssertEqual(country, .at)
    }
}