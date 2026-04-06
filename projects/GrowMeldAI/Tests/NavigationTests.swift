@MainActor
final class NavigationTests: XCTestCase {
    func testNavigateToExam() {
        var path = NavigationPath()
        let nav = NavigationManager(path: .constant(&path))
        nav.navigate(to: .examSimulation(mode: .practice))
        XCTAssertEqual(path.count, 1)
    }
}