// Tests/Models/AIModelStateTests.swift
import XCTest
@testable import DriveAI

class AIModelStateTests: XCTestCase {
    
    // ✅ HAPPY PATH: Equatable conformance works
    func test_ready_equals_ready() {
        let state1 = AIModelState.ready
        let state2 = AIModelState.ready
        XCTAssertEqual(state1, state2)
    }
    
    func test_fallback_equals_fallback() {
        let state1 = AIModelState.fallback
        let state2 = AIModelState.fallback
        XCTAssertEqual(state1, state2)
    }
    
    func test_error_equals_error_regardless_of_message() {
        let error1 = AIModelState.error("Network timeout")
        let error2 = AIModelState.error("Different message")
        XCTAssertEqual(error1, error2)  // Both errors treated as equal
    }
    
    // ✅ EDGE CASE: Different states are not equal
    func test_ready_not_equals_fallback() {
        XCTAssertNotEqual(AIModelState.ready, AIModelState.fallback)
    }
    
    func test_ready_not_equals_error() {
        XCTAssertNotEqual(AIModelState.ready, AIModelState.error("Any error"))
    }
    
    func test_fallback_not_equals_error() {
        XCTAssertNotEqual(AIModelState.fallback, AIModelState.error("Any error"))
    }
    
    // ✅ BEHAVIOR: isFallback computed property
    func test_isFallback_true_when_fallback() {
        XCTAssertTrue(AIModelState.fallback.isFallback)
    }
    
    func test_isFallback_false_when_ready() {
        XCTAssertFalse(AIModelState.ready.isFallback)
    }
    
    func test_isFallback_false_when_error() {
        XCTAssertFalse(AIModelState.error("Any error").isFallback)
    }
}