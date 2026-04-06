import XCTest
@testable import DriveAI

final class AnyCodableTests: XCTestCase {
    
    func testAnyCodable_BoolValue() {
        let bool = AnyCodable.bool(true)
        XCTAssertEqual(bool.boolValue, true)
        XCTAssertNil(bool.stringValue)
    }
    
    func testAnyCodable_StringValue() {
        let string = AnyCodable.string("hello")
        XCTAssertEqual(string.stringValue, "hello")
        XCTAssertNil(string.boolValue)
    }
    
    func testAnyCodable_AsBool_WithBool() {
        let bool = AnyCodable.bool(true)
        XCTAssertEqual(bool.asBool(), true)
    }
    
    func testAnyCodable_AsBool_WithString() {
        let trueString = AnyCodable.string("true")
        XCTAssertEqual(trueString.asBool(), true)
        
        let falseString = AnyCodable.string("false")
        XCTAssertEqual(falseString.asBool(), false)
    }
    
    func testAnyCodable_AsBool_WithInvalidString() {
        let invalid = AnyCodable.string("maybe")
        XCTAssertEqual(invalid.asBool(default: true), true)
    }
    
    func testAnyCodable_AsPositiveDouble_Valid() {
        let number = AnyCodable.double(5.5)
        XCTAssertEqual(number.asPositiveDouble(), 5.5)
    }
    
    func testAnyCodable_AsPositiveDouble_Negative() {
        let number = AnyCodable.double(-5.5)
        XCTAssertNil(number.asPositiveDouble())
    }
    
    func testAnyCodable_AsPositiveDouble_StringCoercion() {
        let string = AnyCodable.string("5.5")
        XCTAssertEqual(string.asPositiveDouble(), 5.5)
    }
    
    func testAnyCodable_Equality() {
        let a = AnyCodable.string("test")
        let b = AnyCodable.string("test")
        let c = AnyCodable.string("different")
        
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }
    
    func testAnyCodable_Init_WithAny() {
        let dict: [String: Any] = ["key": "value", "number": 42]
        let anyCodable = AnyCodable(dict)
        
        XCTAssertNotNil(anyCodable)
    }
}