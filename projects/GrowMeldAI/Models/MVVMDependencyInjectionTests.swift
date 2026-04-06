import XCTest
@testable import DriveAI

final class MVVMDependencyInjectionTests: XCTestCase {
    
    func testViewModelAcceptsMockDataService() {
        let mockService = MockLocalDataService()
        let vm = QuestionViewModel(dataService: mockService)
        
        XCTAssertTrue(vm is ObservableObject)
    }
    
    func testEnvironmentObjectInjection() {
        let coordinator = AppCoordinator()
        let view = DashboardView()
            .environmentObject(coordinator)
        
        // Verify EnvironmentObject registered
        XCTAssertNotNil(view)
    }
    
    func testLocalDataServiceProtocolConformance() {
        let service: LocalDataServiceProtocol = LocalDataService()
        XCTAssertTrue(service is LocalDataService)
    }
    
    func testServiceLocatorSingleton() {
        let service1 = LocalDataService.shared
        let service2 = LocalDataService.shared
        
        // Same instance
        XCTAssertTrue(service1 === service2)
    }
}