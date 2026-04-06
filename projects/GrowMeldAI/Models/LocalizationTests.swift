// Add to test suite
class LocalizationTests: XCTestCase {
    let l10n = LocalizationService.shared
    
    func testAllKeysTranslated() {
        // Scan all LocalizationKey cases
        for key in LocalizationKey.allCases {
            let translated = l10n.string(for: key)
            XCTAssertFalse(translated.contains("ERROR:"), 
                          "Untranslated key: \(key.rawValue)")
        }
    }
    
    func testDateFormattingByRegion() {
        let testDate = Date(timeIntervalSince1970: 0)
        
        l10n.setRegion(.australia)
        XCTAssertEqual(l10n.formattedDate(testDate), "1 Jan 1970") // DD MMM YYYY
        
        l10n.setRegion(.canadaOntario)
        XCTAssertEqual(l10n.formattedDate(testDate), "Jan 1, 1970") // MMM DD, YYYY
    }
    
    func testNumberFormattingByRegion() {
        let number = 1234
        
        l10n.setRegion(.australia)
        XCTAssertEqual(l10n.formattedNumber(number), "1,234") // , separator
        
        l10n.setRegion(.canadaOntario)
        XCTAssertEqual(l10n.formattedNumber(number), "1,234") // same for EN
    }
}