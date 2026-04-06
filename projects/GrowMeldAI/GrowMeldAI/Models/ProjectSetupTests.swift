import XCTest
@testable import DriveAI

final class ProjectSetupTests: XCTestCase {
    
    // MARK: - Bundle & Resources
    
    func testQuestionsCAtalogBundleExists() {
        let bundle = Bundle.main
        let url = bundle.url(forResource: "questions_catalog", withExtension: "json")
        XCTAssertNotNil(url, "questions_catalog.json must exist in bundle")
    }
    
    func testQuestionsCAtalogIsValidJSON() {
        guard let url = Bundle.main.url(forResource: "questions_catalog", withExtension: "json") else {
            XCTFail("questions_catalog.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questions = try decoder.decode([Question].self, from: data)
            
            XCTAssertGreaterThan(questions.count, 0, "Catalog must have at least 1 question")
            XCTAssertGreaterThanOrEqual(questions.count, 50, "Catalog should have 50+ questions")
        } catch {
            XCTFail("Failed to decode questions_catalog.json: \(error)")
        }
    }
    
    func testLocalizationFileExists() {
        let bundle = Bundle.main
        guard let locPath = bundle.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: "de") else {
            XCTFail("Localizable.strings (de) must exist")
            return
        }
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: locPath))
    }
    
    // MARK: - MVVM Base Classes
    
    func testBaseViewModelInitializes() {
        let vm = TestViewModel()
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
    }
    
    func testAppCoordinatorIsObservableObject() {
        let coordinator = AppCoordinator()
        XCTAssertTrue(coordinator is ObservableObject)
    }
    
    func testAppCoordinatorNavigationPathInitialized() {
        let coordinator = AppCoordinator()
        var path = NavigationPath()
        XCTAssertEqual(path.count, 0)
    }
}

// Helper test ViewModel
private class TestViewModel: BaseViewModel {
    @Published var count = 0
}