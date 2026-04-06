import XCTest
@testable import DriveAI

final class TrialConfigTests: XCTestCase {
    
    // MARK: - Issue #3: Non-Throwing Initializer
    
    func test_config_init_nonThrowing() {
        // Should not throw
        let config = TrialConfig(durationDays: 7)
        
        XCTAssertEqual(config.durationDays, 7)
    }
    
    func test_config_init_withDefaults() {
        let config = TrialConfig()
        
        XCTAssertEqual(config.durationDays, 7)
        XCTAssertNil(config.questionsLimit)
        XCTAssertNil(config.categoriesLimit)
    }
    
    func test_config_init_inStateProperty() {
        // This should compile without do/try/catch
        var config = TrialConfig(durationDays: 14)
        XCTAssertEqual(config.durationDays, 14)
    }
    
    // MARK: - Validation (called at service level)
    
    func test_config_validate_validDuration() throws {
        let config = TrialConfig(durationDays: 7)
        
        XCTAssertNoThrow(try config.validate())
    }
    
    func test_config_validate_maxDuration() throws {
        let config = TrialConfig(durationDays: 365)
        
        XCTAssertNoThrow(try config.validate())
    }
    
    func test_config_validate_zeroDuration_throws() {
        let config = TrialConfig(durationDays: 0)
        
        XCTAssertThrowsError(try config.validate()) { error in
            guard case TrialError.invalidState = error as? TrialError else {
                XCTFail("Expected invalidState error")
                return
            }
        }
    }
    
    func test_config_validate_negativeDuration_throws() {
        let config = TrialConfig(durationDays: -7)
        
        XCTAssertThrowsError(try config.validate())
    }
    
    func test_config_validate_exceedMaxDuration_throws() {
        let config = TrialConfig(durationDays: 366)
        
        XCTAssertThrowsError(try config.validate())
    }
    
    func test_config_validate_questionsLimit() throws {
        let config = TrialConfig(durationDays: 7, questionsLimit: 50)
        
        XCTAssertNoThrow(try config.validate())
    }
    
    func test_config_validate_invalidQuestionsLimit_throws() {
        let config = TrialConfig(durationDays: 7, questionsLimit: 0)
        
        XCTAssertThrowsError(try config.validate())
    }
    
    func test_config_isUnlimited() {
        let unlimited = TrialConfig(durationDays: 7)
        XCTAssertTrue(unlimited.isUnlimited)
        
        let limited = TrialConfig(durationDays: 7, questionsLimit: 100)
        XCTAssertFalse(limited.isUnlimited)
    }
    
    func test_config_codable() throws {
        let original = TrialConfig(
            durationDays: 14,
            questionsLimit: 50,
            categoriesLimit: 5
        )
        
        let encoder = JSONEncoder()
        let json = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TrialConfig.self, from: json)
        
        XCTAssertEqual(original, decoded)
    }
}

// Helper for non-throwing assertions
extension XCTestCase {
    func XCTAssertNoThrow<T>(
        _ expression: @autoclosure () throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        do {
            _ = try expression()
        } catch {
            XCTFail("Expected no throw, but got: \(error)", file: file, line: line)
        }
    }
}