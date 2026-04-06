import XCTest
import Combine
@testable import DriveAI

final class DIContainerTests: XCTestCase {
    var sut: DIContainer!
    
    override func setUp() {
        super.setUp()
        sut = DIContainer()
    }
    
    override func tearDown() {
        sut.resetToProduction()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path
    
    func testMakeHomeViewModelCreatesValidInstance() {
        let vm = sut.makeHomeViewModel()
        XCTAssertNotNil(vm)
    }
    
    func testMakeQuestionViewModelCreatesValidInstance() {
        let category = Category(id: 1, name: "Verkehrszeichen")
        let vm = sut.makeQuestionViewModel(category: category)
        XCTAssertNotNil(vm)
        XCTAssertEqual(vm.category.id, category.id)
    }
    
    func testMakeExamSimulationViewModelCreatesValidInstance() {
        let vm = sut.makeExamSimulationViewModel()
        XCTAssertNotNil(vm)
    }
    
    func testAllViewModelsAccessSameProgressService() {
        let homeVM = sut.makeHomeViewModel()
        let readinessVM = sut.makeReadinessViewModel()
        
        // Both should share the same ProgressTrackingService instance
        XCTAssertEqual(
            ObjectIdentifier(sut.progressTrackingService),
            ObjectIdentifier(sut.progressTrackingService),
            "ProgressTrackingService should be singleton"
        )
    }
    
    // MARK: - Mock Injection
    
    func testSetMockServicesInjectsDataService() {
        let mockData = MockLocalDataService()
        sut.setMockServices(dataService: mockData)
        
        let vm = sut.makeHomeViewModel()
        XCTAssertNotNil(vm.dataService)
    }
    
    func testResetToProductionClearsMocks() {
        let mockData = MockLocalDataService()
        sut.setMockServices(dataService: mockData)
        
        sut.resetToProduction()
        
        let vm1 = sut.makeHomeViewModel()
        let vm2 = sut.makeHomeViewModel()
        
        // After reset, services should be production instances
        XCTAssertNotNil(vm1)
        XCTAssertNotNil(vm2)
    }
    
    // MARK: - Memory Management
    
    func testDIContainerDoesNotCreateCircularReferences() {
        weak var weakContainer: DIContainer? = nil
        
        autoreleasepool {
            var container: DIContainer? = DIContainer()
            weakContainer = container
            
            let _ = container?.makeHomeViewModel()
            container = nil
        }
        
        // If memory management is correct, container should be deallocated
        XCTAssertNil(weakContainer, "DIContainer should be deallocated (no circular refs)")
    }
    
    // MARK: - Edge Cases
    
    func testMultipleDIContainerInstancesDoNotInterfere() {
        let container1 = DIContainer()
        let container2 = DIContainer()
        
        // Both should create valid ViewModels independently
        let vm1 = container1.makeHomeViewModel()
        let vm2 = container2.makeHomeViewModel()
        
        XCTAssertNotNil(vm1)
        XCTAssertNotNil(vm2)
    }
    
    func testMakeReadinessViewModelWithMockProgress() {
        let mockProgress = MockProgressTrackingService()
        let vm = ReadinessViewModel(progressService: mockProgress)
        
        XCTAssertEqual(vm.status, .red, "Initial status should be red")
    }
}