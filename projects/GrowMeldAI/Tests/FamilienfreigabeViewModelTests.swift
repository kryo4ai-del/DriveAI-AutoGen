class FamilienfreigabeViewModelTests: XCTestCase {
    func testAddChildWithValidEmail() async {
        let vm = FamilienfreigabeViewModel()
        await vm.addChild(name: "Max", email: "max@example.de", dateOfBirth: Date(timeIntervalSince1970: 0))
        
        XCTAssertEqual(vm.setup.childAccounts.count, 1)
        XCTAssertEqual(vm.setup.childAccounts.first?.email, "max@example.de")
    }
    
    func testAddChildWithInvalidEmail() async {
        let vm = FamilienfreigabeViewModel()
        await vm.addChild(name: "Max", email: "invalid-email", dateOfBirth: Date())
        
        XCTAssertNil(vm.error)  // Should set error
        XCTAssertEqual(vm.setup.childAccounts.count, 0)
    }
}