import XCTest
import Network
@testable import DriveAI

final class NetworkMonitorTests: XCTestCase {
    var monitor: NetworkMonitor!
    
    override func setUp() {
        super.setUp()
        monitor = NetworkMonitor()
    }
    
    override func tearDown() {
        monitor = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path Tests
    
    func testInitialStateIsUnsure() async {
        XCTAssertEqual(monitor.state, .unsure)
        XCTAssertFalse(monitor.isOnline)
    }
    
    func testTransitionToOnlineWiFi() async {
        // Simulate network path change
        let path = MockNWPath(status: .satisfied, usesWifi: true)
        
        await monitor.updateStateForTesting(path)
        
        if case .connected(let type) = monitor.state {
            XCTAssertEqual(type, .wifi)
        } else {
            XCTFail("Expected .connected(.wifi) state")
        }
        XCTAssertTrue(monitor.isOnline)
    }
    
    func testTransitionToOnlineCellular() async {
        let path = MockNWPath(status: .satisfied, usesWifi: false)
        
        await monitor.updateStateForTesting(path)
        
        if case .connected(let type) = monitor.state {
            XCTAssertEqual(type, .cellular)
        } else {
            XCTFail("Expected .connected(.cellular) state")
        }
        XCTAssertTrue(monitor.isOnline)
    }
    
    func testTransitionToOffline() async {
        let path = MockNWPath(status: .unsatisfied)
        
        await monitor.updateStateForTesting(path)
        
        XCTAssertEqual(monitor.state, .disconnected)
        XCTAssertFalse(monitor.isOnline)
    }
    
    // MARK: - State Change Frequency Tests
    
    func testMultipleStateChanges() async {
        let expectations = [
            (MockNWPath(status: .unsatisfied), NetworkState.disconnected),
            (MockNWPath(status: .satisfied, usesWifi: true), 
             NetworkState.connected(.wifi)),
            (MockNWPath(status: .unsatisfied), 
             NetworkState.disconnected),
        ]
        
        for (path, expectedState) in expectations {
            await monitor.updateStateForTesting(path)
            XCTAssertEqual(monitor.state, expectedState)
        }
    }
    
    func testRapidOnOffTransitions() async {
        // Simulate flaky connection
        for _ in 0..<10 {
            await monitor.updateStateForTesting(MockNWPath(status: .satisfied))
            XCTAssertTrue(monitor.isOnline)
            
            await monitor.updateStateForTesting(MockNWPath(status: .unsatisfied))
            XCTAssertFalse(monitor.isOnline)
        }
    }
    
    // MARK: - Publisher Tests
    
    func testIsOnlinePublisherEmitsOnStateChange() async {
        var emissions: [Bool] = []
        let cancellable = monitor.$isOnline.sink { value in
            emissions.append(value)
        }
        
        await monitor.updateStateForTesting(MockNWPath(status: .satisfied))
        await monitor.updateStateForTesting(MockNWPath(status: .unsatisfied))
        
        cancellable.cancel()
        
        // Initial unsure (false) + two state changes
        XCTAssertGreaterThanOrEqual(emissions.count, 2)
        XCTAssertEqual(emissions.last, false)
    }
    
    func testStatePublisherEmitsDetailedUpdates() async {
        var emissions: [NetworkState] = []
        let cancellable = monitor.$state.sink { value in
            emissions.append(value)
        }
        
        await monitor.updateStateForTesting(MockNWPath(status: .satisfied, usesWifi: true))
        await monitor.updateStateForTesting(MockNWPath(status: .satisfied, usesWifi: false))
        
        cancellable.cancel()
        
        XCTAssertGreaterThanOrEqual(emissions.count, 2)
    }
    
    // MARK: - Edge Cases
    
    func testUnknownNetworkTypeHandled() async {
        let path = MockNWPath(status: .satisfied, interfaceType: .unknown)
        
        await monitor.updateStateForTesting(path)
        
        if case .connected(let type) = monitor.state {
            XCTAssertEqual(type, .unknown)
        }
    }
    
    func testMonitorHandlesMultipleInterfaceTypes() async {
        let paths = [
            MockNWPath(status: .satisfied, interfaceType: .wifi),
            MockNWPath(status: .satisfied, interfaceType: .cellular),
            MockNWPath(status: .satisfied, interfaceType: .loopback),
        ]
        
        for path in paths {
            await monitor.updateStateForTesting(path)
            XCTAssertTrue(monitor.isOnline)
        }
    }
    
    func testStateNotChangedIfAlreadyInSameState() async {
        var stateChangeCount = 0
        let cancellable = monitor.$state
            .dropFirst()  // Skip initial .unsure
            .sink { _ in stateChangeCount += 1 }
        
        let path = MockNWPath(status: .satisfied, usesWifi: true)
        
        await monitor.updateStateForTesting(path)
        await monitor.updateStateForTesting(path)
        await monitor.updateStateForTesting(path)
        
        cancellable.cancel()
        
        // Should only emit once (removeDuplicates behavior)
        XCTAssertEqual(stateChangeCount, 1)
    }
}

// MARK: - Mocks

struct MockNWPath {
    let status: NWPath.Status
    let usesWifi: Bool
    let interfaceType: NWInterface.InterfaceType
    
    init(
        status: NWPath.Status,
        usesWifi: Bool = false,
        interfaceType: NWInterface.InterfaceType = .other
    ) {
        self.status = status
        self.usesWifi = usesWifi
        self.interfaceType = interfaceType
    }
}