// Tests/Services/CrashlyticsServiceTests.swift
class CrashlyticsServiceTests: XCTestCase {
    func testInitialize_ReleaseMode() async
    func testLogNonFatalError_QueuesOffline() async
    func testSetCustomValue_ThreadSafe() async
    func testConcurrentLogging_NoRaceConditions() async
}