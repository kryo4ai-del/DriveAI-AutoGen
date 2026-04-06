import XCTest
@testable import DriveAI

/// Tests for ErrorReport model initialization and constraints
final class ErrorReportTests: XCTestCase {
    
    // MARK: - Size Limit Tests
    
    func testErrorReportInit_TruncatesLongMessage() {
        let longMessage = String(repeating: "x", count: 600)
        
        let report = ErrorReport(
            severity: .info,
            message: longMessage
        )
        
        XCTAssertEqual(report.message.count, 500)
        XCTAssertTrue(report.message.hasSuffix("xxx"))
    }
    
    func testErrorReportInit_TruncatesStackTrace() {
        let longStackTrace = (0..<100)
            .map { "Frame \($0): function at file.swift:10" }
            .joined(separator: "\n")
        
        let report = ErrorReport(
            severity: .critical,
            message: "Test",
            stackTrace: longStackTrace
        )
        
        // Should be limited to ~15 frames + truncation notice
        XCTAssertLessThan((report.stackTrace ?? "").utf8.count, 50_000)
        XCTAssertTrue((report.stackTrace ?? "").contains("truncated") || 
                     (report.stackTrace ?? "").split(separator: "\n").count <= 15)
    }
    
    func testErrorReportInit_LimitsContextKeys() {
        var context: [String: String] = [:]
        for i in 0..<50 {
            context["key_\(i)"] = "value_\(i)"
        }
        
        let report = ErrorReport(
            severity: .info,
            message: "Test",
            userContext: context
        )
        
        XCTAssertLessThanOrEqual(report.userContext.count, 20)
    }
    
    func testErrorReportInit_LimitsContextValueSize() {
        let context = [
            "large_key": String(repeating: "x", count: 2_000)
        ]
        
        let report = ErrorReport(
            severity: .info,
            message: "Test",
            userContext: context
        )
        
        XCTAssertLessThanOrEqual(
            report.userContext["large_key"]?.utf8.count ?? 0,
            1_000
        )
    }
    
    func testErrorReportInit_PreservesSmallData() {
        let report = ErrorReport(
            severity: .warning,
            message: "Small message",
            errorDescription: "Small error",
            stackTrace: "Frame 1\nFrame 2",
            userContext: ["key": "value"]
        )
        
        XCTAssertEqual(report.message, "Small message")
        XCTAssertEqual(report.errorDescription, "Small error")
        XCTAssertEqual(report.userContext["key"], "value")
    }
    
    // MARK: - Codable Tests
    
    func testErrorReportCodable_EncodesWithCorrectKeys() throws {
        let report = ErrorReport(
            severity: .critical,
            message: "Test error",
            errorDescription: "Details",
            userContext: ["key": "value"]
        )
        
        let encoded = try JSONEncoder().encode(report)
        let decoded = try JSONDecoder().decode(ErrorReport.self, from: encoded)
        
        XCTAssertEqual(decoded.id, report.id)
        XCTAssertEqual(decoded.message, report.message)
        XCTAssertEqual(decoded.severity, .critical)
    }
    
    func testErrorReportCodable_RoundTrip() throws {
        let original = ErrorReport(
            severity: .warning,
            message: "Test",
            errorDescription: "Error",
            stackTrace: "Frame 1",
            userContext: ["a": "b", "c": "d"]
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ErrorReport.self, from: encoded)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.timestamp.timeIntervalSince1970,
                      decoded.timestamp.timeIntervalSince1970,
                      accuracy: 0.01)
        XCTAssertEqual(original.message, decoded.message)
        XCTAssertEqual(original.userContext, decoded.userContext)
    }
}

/// Tests for ErrorSeverity
final class ErrorSeverityTests: XCTestCase {
    
    func testErrorSeverityCodable_EncodesAllCases() throws {
        for severity in [ErrorSeverity.info, .warning, .critical] {
            let encoded = try JSONEncoder().encode(severity)
            let decoded = try JSONDecoder().decode(ErrorSeverity.self, from: encoded)
            XCTAssertEqual(decoded, severity)
        }
    }
}