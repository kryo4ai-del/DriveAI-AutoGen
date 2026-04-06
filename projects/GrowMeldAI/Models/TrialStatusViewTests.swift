class TrialStatusViewTests: XCTestCase {
    func testActiveTrialSnapshot() {
        let vm = TrialViewModel(state: .active(expiresAt: Date().addingTimeInterval(3 * 86400)))
        let view = TrialStatusView().environmentObject(vm)
        assertSnapshot(matching: view)
    }
}